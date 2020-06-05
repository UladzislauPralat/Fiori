@AbapCatalog.sqlViewName: 'ZBWTBL1'
@EndUserText.label: 'Date'
//HANA Optimized Cube
define view z_bw_table_1 as select from rsdcube left outer join rsdcubet
                                                             on rsdcube.infocube = rsdcubet.infocube
                                                            and rsdcube.objvers = rsdcubet.objvers
                                                            and rsdcubet.langu = 'E' 
{
  key cast(rsdcube.infocube as abap.char( 50 ) ) as Object,
  key cast('HANA Optimized Cube F-Table' as text30 ) as TableType,   
      cast( case substring(rsdcube.infocube,1,1)
      when '0' then concat('/BI0/F',rsdcube.infocube) 
      else concat('/BIC/F',rsdcube.infocube) end as tabname) as TableName,
      rsdcubet.txtlg as TableDesc
} where rsdcube.transact = ''
    and rsdcube.objvers = 'A'
    and rsdcube.infocube not like '/%'
    and rsdcube.cubetype = 'B'
    and rsdcube.cubesubtype = 'F'

union all

// Standad Cube F-table
select from rsdcube left outer join rsdcubet
                                 on rsdcube.infocube = rsdcubet.infocube
                                and rsdcube.objvers = rsdcubet.objvers
                                and rsdcubet.langu = 'E' 
{
  key cast(rsdcube.infocube as abap.char( 50 ) ) as Object,
  key cast('Standard Cube F-Table' as text30 ) as TableType,  
      cast( case substring(rsdcube.infocube,1,1)
      when '0' then concat('/BI0/F',rsdcube.infocube) 
      else concat('/BIC/F',rsdcube.infocube) end as tabname) as TableName,
      rsdcubet.txtlg as TableDesc      
} where rsdcube.transact = ''
    and rsdcube.objvers = 'A'
    and rsdcube.infocube not like '/%'    
    and rsdcube.cubetype = 'B'    
    and rsdcube.cubesubtype = ' '
    
union all

// Standad Cube E-table
select from rsdcube left outer join rsdcubet
                                 on rsdcube.infocube = rsdcubet.infocube
                                and rsdcube.objvers = rsdcubet.objvers
                                and rsdcubet.langu = 'E'
{
  key cast( rsdcube.infocube as abap.char( 50 ) ) as Object,
  key cast('Standad Cube E-table' as text30 ) as TableType,  
      cast( case substring(rsdcube.infocube,1,1)
      when '0' then concat('/BI0/E',rsdcube.infocube) 
      else concat('/BIC/E',rsdcube.infocube) end as tabname) as TableName,
      rsdcubet.txtlg as TableDesc      
} where rsdcube.transact = ''
    and rsdcube.objvers = 'A'
    and rsdcube.infocube not like '/%'    
    and rsdcube.cubetype = 'B'    
    and rsdcube.cubesubtype = ' '   
    
union all
    
// Classic DSO Active Table    
select from rsdodso left outer join rsdodsot
                                 on rsdodso.odsobject = rsdodsot.odsobject
                                and rsdodso.objvers = rsdodsot.objvers
                                and rsdodsot.langu = 'E'
{
  key cast( rsdodso.odsobject as abap.char( 50 ) ) as Object,
  key cast('Classic DSO Active Table' as text30 ) as TableType,  
      cast( case substring(rsdodso.odsobject,1,1)
      when '0' then concat(concat('/BI0/A',rsdodso.odsobject),'00') 
      else concat(concat('/BIC/A',rsdodso.odsobject),'00') end as tabname) as TableName,
      rsdodsot.txtlg as TableDesc      
} where rsdodso.objvers = 'A'
    and rsdodso.odsotype = ' '
    and rsdodso.odsobject not like '/%'
    
union all
    
// Classic DSO Change Log Table    
select from z_rsdodso inner join rstsods
                              on z_rsdodso.odsname = rstsods.odsname
                             and rstsods.version = '000'
                      left outer join rsdodsot
                                   on z_rsdodso.odsobject = rsdodsot.odsobject
                                  and z_rsdodso.objvers = rsdodsot.objvers
                                  and rsdodsot.langu = 'E'                            
{
  key cast( z_rsdodso.odsobject as abap.char( 50 ) ) as Object,
  key cast('Classic DSO Change Log' as text30 ) as TableType,  
      cast( rstsods.odsname_tech as tabname) as TableName,
      rsdodsot.txtlg as TableDesc       
} where z_rsdodso.objvers = 'A'
    and z_rsdodso.odsotype = ' '
    and z_rsdodso.odsobject not like '/%'    
    
union all
    
// Classic DSO Inbound Queue    
select from rsdodso left outer join rsdodsot
                                 on rsdodso.odsobject = rsdodsot.odsobject
                                and rsdodso.objvers = rsdodsot.objvers
                                and rsdodsot.langu = 'E'
{
  key cast( rsdodso.odsobject as abap.char( 50 ) ) as Object,
  key cast('Classic DSO Activation Queue' as text30 ) as TableType,  
      cast( case substring(rsdodso.odsobject,1,1)
      when '0' then concat(concat('/BI0/A',rsdodso.odsobject),'40') 
      else concat(concat('/BIC/A',rsdodso.odsobject),'40') end as tabname) as TableName,
      rsdodsot.txtlg as TableDesc      
} where rsdodso.objvers = 'A'
    and rsdodso.odsotype = ' '
    and rsdodso.odsobject not like '/%'    

union all

// Advanced DSO Inbound Table    
select from rsoadso left outer join rsoadsot
                                 on rsoadso.adsonm = rsoadsot.adsonm
                                and rsoadso.objvers = rsoadsot.objvers
                                and rsoadsot.colname = ''
                                and rsoadsot.langu = 'E'
{
  key cast( rsoadso.adsonm as abap.char( 50 ) ) as Object,
  key cast('Advanced DSO Inbound Table' as text30 ) as TableType,  
      cast( case substring(rsoadso.adsonm,1,1)
      when '0' then concat(concat('/BI0/A',rsoadso.adsonm),'1') 
      else concat(concat('/BIC/A',rsoadso.adsonm),'1') end as tabname) as TableName,
      substring(rsoadsot.description,1,60) as TableDesc    
} where rsoadso.objvers = 'A'
    and rsoadso.adsonm not like '/%'
    
union all

// Advanced DSO Active Data Table    
select from rsoadso left outer join rsoadsot
                                 on rsoadso.adsonm = rsoadsot.adsonm
                                and rsoadso.objvers = rsoadsot.objvers
                                and rsoadsot.colname = ''
                                and rsoadsot.langu = 'E'
{
  key cast( rsoadso.adsonm as abap.char( 50 ) ) as Object,
  key cast('Advanced DSO Active Data Table' as text30 ) as TableType,  
      cast( case substring(rsoadso.adsonm,1,1)
      when '0' then concat(concat('/BI0/A',rsoadso.adsonm),'2') 
      else concat(concat('/BIC/A',rsoadso.adsonm),'2') end as tabname) as TableName ,
      substring(rsoadsot.description,1,60) as TableDesc      
} where rsoadso.objvers = 'A'
    and rsoadso.adsonm not like '/%'    
    
union all

// Advanced DSO Change Log    
select from rsoadso left outer join rsoadsot
                                 on rsoadso.adsonm = rsoadsot.adsonm
                                and rsoadso.objvers = rsoadsot.objvers
                                and rsoadsot.colname = ''
                                and rsoadsot.langu = 'E'
{
  key cast( rsoadso.adsonm as abap.char( 50 ) ) as Object,
  key cast('Advanced DSO Change Log' as text30 ) as TableType,  
      cast( case substring(rsoadso.adsonm,1,1)
      when '0' then concat(concat('/BI0/A',rsoadso.adsonm),'3') 
      else concat(concat('/BIC/A',rsoadso.adsonm),'3') end as tabname) as TableName,
      substring(rsoadsot.description,1,60) as TableDesc       
} where rsoadso.objvers = 'A'
    and rsoadso.adsonm not like '/%'    
    
union all

// 3.x DataSource PSA    
select from z_rsdsts left outer join rsoltpsourcet
                                  on z_rsdsts.datasource = rsoltpsourcet.oltpsource
                                 and z_rsdsts.logsys = rsoltpsourcet.logsys 
                                 and rsoltpsourcet.objvers = 'A'
                                 and rsoltpsourcet.langu = 'E'
{
  key cast( concat_with_space(concat_with_space(z_rsdsts.datasource, '/', 1), z_rsdsts.logsys, 1 ) as abap.char( 50 ) ) as Object,
  key cast('3.x DataSource PSA' as text30 ) as TableType,  
      cast( z_rsdsts.psa_table as tabname16) as TableName,
      rsoltpsourcet.txtlg as TableDesc      
}     

union all

// 7.x DataSource PSA
select from z_rstsods
{
  key cast( concat_with_space(concat_with_space(datasource, '/', 1), logsys, 1 ) as abap.char( 50 ) ) as Object,
  key cast('7.x DataSource PSA' as text30 ) as TableType,  
  cast( odsname_tech as tabname16) as TableName,
  txtlg as TableDesc        
}
