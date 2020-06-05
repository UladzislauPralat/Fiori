@AbapCatalog.sqlViewName: 'ZRSDSTS'
@EndUserText.label: '3.x DataSource PSA'
define view z_rsdsts as select from rsdsts   
{
  key datasource,
  key logsys,
  max( psa_version ) as psa_version,  
  max( psa_table ) as psa_table
}
where objvers = 'A'
group by datasource, logsys