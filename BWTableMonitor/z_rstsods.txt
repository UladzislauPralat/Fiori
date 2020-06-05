@AbapCatalog.sqlViewName: 'ZRSTSODS'
@EndUserText.label: '7.x DataSource PSA'
define view z_rstsods as select from rsdsseg inner join rstsods
                                                     on rsdsseg.psa = rstsods.odsname   
                                             left outer join rsdssegt
                                                          on rsdsseg.datasource = rsdssegt.datasource
                                                         and rsdsseg.logsys     = rsdssegt.logsys 
                                                         and rsdsseg.objvers    = rsdssegt.objvers
                                                         and rsdsseg.segid      = rsdssegt.segid                                       
                                                         and rsdssegt.langu     = 'E'
{
  key rsdsseg.datasource,
  key rsdsseg.logsys,
  rsdssegt.txtlg,
  max( rstsods.version ) as version,
  max( rstsods.odsname_tech ) as odsname_tech
}
where rsdsseg.objvers = 'A'
  and rsdsseg.segid = '0001' 
group by rsdsseg.datasource, rsdsseg.logsys, rsdssegt.txtlg