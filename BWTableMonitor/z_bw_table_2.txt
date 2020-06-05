@AbapCatalog.sqlViewName: 'ZBWTBL2'
@EndUserText.label: 'Date'
define view z_bw_table_2 as select from z_bw_table_1 inner join tadir
                                                             on z_bw_table_1.TableName = tadir.obj_name
                                                              
{
  key z_bw_table_1.Object,
  key z_bw_table_1.TableType,   
      z_bw_table_1.TableName,
      z_bw_table_1.TableDesc
}   