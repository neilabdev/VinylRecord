#define mapping_do(mapping) \
    + (void) initializeMapping { \
        mapping \
    }

#define column_name(properyName, columnName) \
    [self performSelector : @selector(addMappingOn:column:) \
     withObject : @ ""#properyName "" \
     withObject : @ ""#columnName ""];


#define column_map(properyName, columnMap) \
    [self performSelector : @selector(addMappingOn:mapping:) \
     withObject : @ ""#properyName "" \
     withObject : @ ""#columnMap ""];