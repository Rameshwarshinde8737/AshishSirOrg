import { LightningElement } from 'lwc';

export default class Utils extends LightningElement {}

// objectHelper.js
// Works with lodash + deepdash that you load from static resources.
// Pass window._ into each function (already deepdash-augmented).
// Children property is "ChildRecords" by default.

const CHILD_KEY = "ChildRecords";

function ensureKids(n) {
  if (!Array.isArray(n[CHILD_KEY])) n[CHILD_KEY] = [];
  return n[CHILD_KEY];
}

// Find a node by Id (using deepdash's findDeep)
export function findById(tree, id, _) {
  if (!Array.isArray(tree) || !id || !_) return null;
  const hit = _.findDeep(
    tree,
    (v) => _.isPlainObject(v) && v.Id === id,
    { childrenPath: CHILD_KEY, leavesOnly: false }
  );
  return hit || null;
}

export function getObjectById(tree, id,_) {
    if (!Array.isArray(tree) || !id) return null;

    const hit = _.findDeep(
        tree,
        (value) => _.isPlainObject(value) && value.Id === id,
        { childrenPath: 'childRecords', leavesOnly: false }
    );

    return hit ? hit.value : null;
}

/**
 * mutateTree: single entry point
 * Supported actions:
 *  - { type:'add', parentId?:string, node:object }
 *  - { type:'addMany', parentId?:string, nodes:object[] }
 *  - { type:'update', id:string, patch:object }           // shallow
 *  - { type:'delete', id:string }
 *  - { type:'setKey', id:string, key:string, value:any }
 *  - { type:'renameKey', id:string, from:string, to:string }
 */
export function mutateTree(input, action, _) {
  if (!_) return input;
  let tree = _.cloneDeep(input || []);

  switch (action?.type) {
    case "add": {
      const { parentId, node } = action;
      if (!node) return tree;
      if (!parentId) return [...tree, node];
      const parentHit = findById(tree, parentId, _);
      if (!parentHit) return tree;
      ensureKids(parentHit.value).push(node);
      return tree;
    }

    case "addMany": {
      const { parentId, nodes } = action;
      const items = Array.isArray(nodes) ? nodes : [];
      if (!parentId) return [...tree, ...items];
      const parentHit = findById(tree, parentId, _);
      if (!parentHit) return tree;
      ensureKids(parentHit.value).push(...items);
      return tree;
    }

    case "update": {
      const { id, patch } = action;
      if (!id || !patch) return tree;
      const hit = findById(tree, id, _);
      if (!hit) return tree;
      Object.assign(hit.value, patch); // shallow; swap to _.merge for deep
      return tree;
    }

    case "delete": {
      const { id } = action;
      if (!id) return tree;

      // Replace ChildRecords arrays immutably as we bubble up
      const removeById = (nodes) => {
        let changed = false;
        const next = nodes
          .map(n => {
            if (!n) return n;
            if (n.Id === id) {
              changed = true;
              return null; // mark for removal
            }
            const kids = Array.isArray(n[CHILD_KEY]) ? removeById(n[CHILD_KEY]) : n[CHILD_KEY];
            if (kids !== n[CHILD_KEY]) {
              changed = true;
              return { ...n, [CHILD_KEY]: kids };
            }
            return n;
          })
          .filter(Boolean);
        return changed ? next : nodes;
      };

      return removeById(tree);
    }

    case "setKey": {
      const { id, key, value } = action;
      const hit = key ? findById(tree, id, _) : null;
      if (!hit) return tree;
      hit.value[key] = value;
      return tree;
    }

    case "renameKey": {
      const { id, from, to } = action;
      const hit = (from && to) ? findById(tree, id, _) : null;
      if (!hit) return tree;
      if (Object.prototype.hasOwnProperty.call(hit.value, from)) {
        hit.value[to] = hit.value[from];
        delete hit.value[from];
      }
      return tree;
    }

    default:
      return tree;
  }
}

/**
 * attachChildren: attach an array of children under a parent
 * - Avoids dupes
 * - Computes parentId, depth, hierKey on the children
 */
export function attachChildren(tree, parentId, children, _,expandParent = false) {
  if (!Array.isArray(tree) || !parentId || !_) return tree;
  const t = _.cloneDeep(tree);
  const parentHit = findById(t, parentId, _);
  if (!parentHit) return t;

  const parent = parentHit.value;
  ensureKids(parent);

  if (!Array.isArray(parent.hierKey) || parent.hierKey.length === 0) {
    parent.hierKey = [parent.Id];
  }
  if (typeof parent.depth !== "number") parent.depth = parent.hierKey.length - 1;

  const existing = new Set(parent[CHILD_KEY].map(c => c.Id));
  for (const c of (children || [])) {
    if (!c || !c.Id || existing.has(c.Id)) continue;
    c.parentId = parent.Id;
    c.depth = (parent.depth || 0) + 1;
    c.hierKey = [...parent.hierKey, c.Id];
    if (!Array.isArray(c[CHILD_KEY])) c[CHILD_KEY] = [];
    parent[CHILD_KEY].push(c);
    existing.add(c.Id);
  }
  // Only expand if explicitly requested
  if (expandParent) parent.expanded = true;
  return t;
}

/**
 * collapseDescendants: set expanded=false for the whole subtree
 */
export function collapseDescendants(tree, id, _) {
  if (!Array.isArray(tree) || !id || !_) return tree;
  const t = _.cloneDeep(tree);
  const hit = findById(t, id, _);
  if (!hit) return t;

  const dfs = (n) => {
    if (!n) return;
    n.expanded = false;
    n.chevronIcon = "icon-uniA20";
    if (Array.isArray(n[CHILD_KEY])) n[CHILD_KEY].forEach(dfs);
  };
  if (Array.isArray(hit.value[CHILD_KEY])) hit.value[CHILD_KEY].forEach(dfs);
  return t;
}

/**
 * addKeyInObject: decorate every node in the tree (deep map)
 * decorator(node) -> object to merge
 */
export function addKeyInObject(data, decorator, _) {
  if (!Array.isArray(data) || !_ || typeof decorator !== "function") return data;
  const t = _.cloneDeep(data);

  _.eachDeep(
    t,
    (value, key, parent, ctx) => {
      if (_.isPlainObject(value) && value.Id) {
        const extra = decorator(value) || {};
        Object.assign(value, extra);
        if (!Array.isArray(value[CHILD_KEY])) value[CHILD_KEY] = value[CHILD_KEY] || [];
      }
    },
    { childrenPath: CHILD_KEY }
  );

  return t;
}
export function findTopParent(data, targetId) {
  // Build a flat map for quick lookup by Id
  const idMap = new Map();

  function buildMap(records) {
    for (const item of records) {
      idMap.set(item.Id, item);
      if (item.ChildRecords && item.ChildRecords.length > 0) {
        buildMap(item.ChildRecords);
      }
    }
  }

  buildMap(data);

  // Start from the target node
  let current = idMap.get(targetId);
  if (!current) return null;

  // Walk up using parentId until no more parent exists
  while (current.parentId && idMap.has(current.parentId)) {
    current = idMap.get(current.parentId);
  }

  return current;
}
export const CHILDREN_KEY = CHILD_KEY;