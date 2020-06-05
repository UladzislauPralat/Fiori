@AbapCatalog.sqlViewName: 'ZRSDODSO'
@EndUserText.label: 'Classic DSO Change Log'
define view z_rsdodso as select from rsdodso inner join z_rsbasidoc
                                                     on z_rsbasidoc.mandt = $session.client
{
  key rsdodso.odsobject,
  key rsdodso.objvers,
      rsdodso.odsotype,
      concat(concat(concat('8',rsdodso.odsobject),'_'),z_rsbasidoc.tsprefix) as odsname
} 