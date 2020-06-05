@AbapCatalog.sqlViewName: 'ZRSBASIDOC'
@EndUserText.label: 'Source Systems'
define view z_rsbasidoc as select from t000 inner join rsbasidoc
                                                    on t000.logsys = rsbasidoc.slogsys
                                                   and t000.logsys = rsbasidoc.rlogsys
                                                   and srctype = 'M'
{ t000.mandt,
  t000.logsys,
  rsbasidoc.tsprefix 
} 
where mandt = $session.client