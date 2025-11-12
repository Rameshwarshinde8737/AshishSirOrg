public virtual interface CRUDBehaviour {

    boolean isAccessible();

    boolean isUpdateable();

    boolean isCreateable();

    boolean isDeletable();
    
}