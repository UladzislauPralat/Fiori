class ZCL_TILE_NUM_BT definition
  public
  final
  create public .

public section.

  constants C_NEGATIVE type STRING value 'Negative' ##NO_TEXT.
  constants C_NEUTRAL type STRING value 'Neutral' ##NO_TEXT.
  constants C_POSITIVE type STRING value 'Positive' ##NO_TEXT.
  constants C_GOOD type STRING value 'Good' ##NO_TEXT.
  constants C_ERROR type STRING value 'Error' ##NO_TEXT.
  constants C_DOWN type STRING value 'Down' ##NO_TEXT.
  constants C_NONE type STRING value 'None' ##NO_TEXT.
  constants C_UP type STRING value 'Up' ##NO_TEXT.
  constants C_M type STRING value 'M' ##NO_TEXT.
  constants C_B type STRING value 'B' ##NO_TEXT.
  constants C_K type STRING value 'K' ##NO_TEXT.

  class-methods GET_ENTITY
    importing
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_BT_MPC=>TS_ZTILE_NUM_BT .
protected section.
private section.

  class-methods GET_ENTITY_FLIGHT_OCC
    returning
      value(RS_ENTITY) type ZCL_ZTILE_NUM_BT_MPC=>TS_ZTILE_NUM_BT .
 
	...
ENDCLASS.



CLASS ZCL_TILE_NUM_BT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TILE_NUM_BT=>GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_BT_MPC=>TS_ZTILE_NUM_BT
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity.

  DATA(wt_keys) = io_tech_request_context->get_keys( ).
  TRY.
    DATA(w_title) = wt_keys[ name = 'TITLE' ]-value.
    DATA(w_method) = REPLACE( val =  |GET_ENTITY_{ w_title CASE = UPPER }| regex = '\s' WITH = '_' OCC = 0 ).
    CALL METHOD (w_method) RECEIVING rs_entity = rs_entity.
  CATCH cx_sy_itab_line_not_found cx_sy_dyn_call_error.
  ENDTRY.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_TILE_NUM_BT=>GET_ENTITY_FLIGHT_OCC
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_ENTITY                      TYPE        ZCL_ZTILE_NUM_BT_MPC=>TS_ZTILE_NUM_BT
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD get_entity_flight_occ.

  rs_entity = VALUE #(
    icon             = 'sap-icon://waiver'
    number           = '76.5'
    numberDigits     = '5'
    numberFactor     = ''
    numberState      = 'Error'                           "Positive or Error
    numberUnit       = '%'
    subtitle         = 'Dec 2017'
    title            = 'Fast Jet Seats Occupancy'
    unit1            = '%'
    unit2            = '%'
    targetValue      = CONV ad_percnt3( '85' )
    targetValueLabel = '85'
    minValue         = 0
    maxValue         = '100'
    actual           = CONV ad_percnt3( '76.5' )
    color            = 'Error'                            "Good or Error
    scale            = '' ).

ENDMETHOD.

	...

ENDCLASS.