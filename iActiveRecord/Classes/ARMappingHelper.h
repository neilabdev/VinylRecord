#define mapping_do(mapping) \
    + (void) initializeMapping { \
        mapping \
    }

#define table_name(tableName) \
    [self performSelector : @selector(addMappingOn:column:) \
     withObject : @"__table__" \
     withObject : @ ""#tableName ""];

#define column_name(propertyName, columnName) \
    [self performSelector : @selector(addMappingOn:column:) \
     withObject : @ ""#propertyName "" \
     withObject : @ ""#columnName ""];


#define column_map(propertyName, columnMap) \
    [self performSelector : @selector(addMappingOn:mapping:) \
     withObject : @ ""#propertyName "" \
     withObject : columnMap ];