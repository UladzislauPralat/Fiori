REPORT zbw_table_monitor.
sy-title = 'BW Table Monitor'.

START-OF-SELECTION.


SELECT object, tabletype, tablename, tabledesc, CAST( 0 as int8 ) as recordcount, CAST( 0 AS dec ) as size_mb
FROM z_bw_table_2
INTO TABLE @DATA(wt_bw_table).

DATA(w_count) = LINES( wt_bw_table ).
CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
          percentage = 0
          text       = |0% completed|.
DATA(w_index) = 1.
LOOP AT wt_bw_table ASSIGNING FIELD-SYMBOL(<s_bw_table>).
  SELECT COUNT( * ) as recordcount
  INTO <s_bw_table>-recordcount
  FROM (<s_bw_table>-tablename).
*
  DATA: w_tablen TYPE cctablen.
  CALL FUNCTION 'SCCR_GET_NAMETAB_AND_TABLEN'
       EXPORTING
            tabname    = <s_bw_table>-tablename
       IMPORTING
            tablen     = w_tablen
       EXCEPTIONS
            OTHERS     = 1.
  <s_bw_table>-size_mb = ( <s_bw_table>-recordcount * w_tablen ) / ( 1024 * 1024 ).
*
  DATA(w_progress) = w_index * 100 / w_count.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 0
            text       = |{ w_progress } % completed|.
  w_index = w_index + 1.
ENDLOOP.
SORT wt_bw_table BY size_mb DESCENDING.

cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv)
                        CHANGING  t_table      = wt_bw_table ).
salv->get_columns( )->set_optimize( abap_true ).
salv->get_functions( )->set_all( abap_true ).
salv->get_columns( )->get_column( 'OBJECT' )->set_medium_text( 'Object' ).
salv->get_columns( )->get_column( 'TABLETYPE' )->set_medium_text( 'Table Type' ).
salv->get_columns( )->get_column( 'TABLENAME' )->set_medium_text( 'Table Name' ).
salv->get_columns( )->get_column( 'TABLEDESC' )->set_medium_text( 'Table Description' ).
salv->get_columns( )->get_column( 'RECORDCOUNT' )->set_medium_text( 'Record Count' ).
salv->get_columns( )->get_column( 'SIZE_MB' )->set_medium_text( 'Size in Mb' ).
salv->display( ).