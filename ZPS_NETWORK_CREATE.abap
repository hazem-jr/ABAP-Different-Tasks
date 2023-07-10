*&---------------------------------------------------------------------*
*& Report ZPS_NETWORKS_CREATE
*&---------------------------------------------------------------------*
*& Auther : Hazem
*& 09.10.2022
*&---------------------------------------------------------------------*
REPORT zps_networks_create.

CLASS lcl_main DEFINITION.
  PUBLIC SECTION .
    CLASS-METHODS :
      start IMPORTING p_file1 TYPE rlgrap-filename
                      p_file2 TYPE rlgrap-filename .

    METHODS :
      get_file_path
        CHANGING p_file TYPE rlgrap-filename .

  PRIVATE SECTION .
    TYPES : BEGIN OF str_upload,
              " SEQ                  TYPE CHAR4  , " defrentiate between documents to post
              project_definition   TYPE ps_pspid,
              profile              TYPE profidnzpl,
              wbs_element          TYPE ps_posid,
              network              TYPE nw_aufnr,
              network_type         TYPE nw_auart,
              plant                TYPE werks_d,
              short_text           TYPE auftext,
              mrp_controller       TYPE co_dispo,
              activity             TYPE cn_vornr,
              description          TYPE ltxa1,
              control_key          TYPE steus,
              factory_calendar     TYPE wfcid,
              matl_group           TYPE matkl,
              purch_org            TYPE ekorg,
              pur_group            TYPE ekgrp,
              price                TYPE preis,
              price_unit           TYPE peinh,
              work_activity        TYPE arbeit ,   " activity qty
              un_work              TYPE arbeite,   " activity unit
              duration_normal      TYPE daunor,
              duration_normal_unit TYPE daunore,
              plnd_delry           TYPE plifz,
              cost_elem            TYPE kstar,
*              RELATION_TYPE        TYPE IFAOBAR,
*              NETWORK_PREDECESSOR  TYPE AUF_NETNR,
*              ACTIVITY_PREDECESSOR TYPE CN_VORNR,
*              NETWORK_SUCCESSOR    TYPE AUF_NETNR,
*              ACTIVITY_SUCCESSOR   TYPE CN_VORNR,

            END OF  str_upload ,

            BEGIN OF str_relation ,
              project_definition   TYPE ps_pspid,
              relation_type        TYPE ifaobar,
              network_predecessor  TYPE auf_netnr,
              activity_predecessor TYPE cn_vornr,
              network_successor    TYPE auf_netnr,
              activity_successor   TYPE cn_vornr,
              DURATION_RELATION    type AOBDAUER ,
              DURATION_RELATION_UNIT type AOBDAUEH ,

            END OF str_relation ,


            BEGIN OF str_log ,
              project_definition TYPE ps_pspid,
              entity             TYPE char100,
              log_text           TYPE char255,
            END OF str_log  .

    CLASS-DATA : lt_log TYPE TABLE OF str_log,
                 ls_log TYPE str_log.

    CLASS-DATA : lt_upload TYPE TABLE OF str_upload .
    CLASS-DATA : lt_relations TYPE TABLE OF str_relation .

    CLASS-METHODS:
      upload_from_template
        IMPORTING  p_file  TYPE rlgrap-filename
        CHANGING   p_table TYPE STANDARD TABLE
        EXCEPTIONS conversion_failed ,


      create_documents ,
      p_conversion_ext_to_int CHANGING p TYPE clike    ,

      display_data .


ENDCLASS .
CLASS lcl_main IMPLEMENTATION.
  METHOD get_file_path .

    DATA: lt_file TYPE filetable,
          lv_rc   TYPE i.
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      CHANGING
        file_table              = lt_file   " capture File path
        rc                      = lv_rc     "row count
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.


    IF line_exists( lt_file[ 1 ] ) .
      p_file =  lt_file[ 1 ] .
    ENDIF .

  ENDMETHOD .
  METHOD upload_from_template .

    DATA: file_path TYPE string.
    DATA: lr_columns TYPE REF TO cl_salv_columns_table,
          lr_column  TYPE REF TO cl_salv_column_table.
    DATA: r_salv TYPE REF TO cl_salv_table.

    DATA : i_raw      TYPE  truxs_t_text_data,
           i_filename TYPE  rlgrap-filename.

    BREAK xabap.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_line_header        = 'X'
        i_tab_raw_data       = i_raw
        i_filename           = p_file
      TABLES
        i_tab_converted_data = p_table "LT_UPLOAD
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF sy-subrc <> 0.
      CASE sy-subrc .
        WHEN 1.
          RAISE conversion_failed.
      ENDCASE .
    ENDIF .

  ENDMETHOD.

  METHOD create_documents .

    TYPES : BEGIN OF ty_map ,
              project_definition TYPE ps_pspid,
              network_ex         TYPE nw_aufnr , " external network number
              network_it         TYPE nw_aufnr , " internal network number
            END OF ty_map .

    DATA : i_method_project  TYPE TABLE OF bapi_method_project, ls_method_project TYPE bapi_method_project,
           i_network         TYPE TABLE OF bapi_network,ls_network TYPE bapi_network,
           i_activity        TYPE TABLE OF bapi_network_activity, ls_activity TYPE bapi_network_activity,
           i_relation        TYPE TABLE OF bapi_network_relation, ls_relation TYPE bapi_network_relation,
           e_message_table   TYPE TABLE OF bapi_meth_message, ls_message_table  TYPE bapi_meth_message,
           ls_main_params    LIKE LINE OF lt_upload,
           lt_map            TYPE TABLE OF ty_map, ls_map TYPE ty_map .

    DATA : net_refnumber TYPE ifrefnum VALUE 0,
           act_refnumber TYPE ifrefnum VALUE 0,
           rel_refnumber TYPE ifrefnum VALUE 0.

    BREAK xabap.
    LOOP AT lt_upload INTO DATA(ls_upload).

*& move network data from sheet to bapi
      p_conversion_ext_to_int( CHANGING p = ls_upload-network ).
      IF ls_upload-network_type IS NOT INITIAL .

        p_conversion_ext_to_int( CHANGING p = ls_upload-mrp_controller ).
        MOVE-CORRESPONDING ls_upload TO ls_network .
        APPEND ls_network TO i_network .

        net_refnumber = net_refnumber + 1 .
        MOVE net_refnumber TO ls_method_project-refnumber.
        MOVE 'NETWORK' TO ls_method_project-objecttype.
        MOVE 'CREATE' TO ls_method_project-method.
        MOVE  ls_upload-network TO ls_method_project-objectkey.
        APPEND ls_method_project TO i_method_project .
        CLEAR ls_method_project .

        p_conversion_ext_to_int( CHANGING p = ls_upload-pur_group ).
        p_conversion_ext_to_int( CHANGING p = ls_upload-activity ).
        p_conversion_ext_to_int( CHANGING p = ls_upload-cost_elem ).
      ENDIF .

      MODIFY lt_upload FROM ls_upload .

      AT END OF project_definition  .

*& create networks
        MOVE 'SAVE' TO ls_method_project-method.
        APPEND ls_method_project TO i_method_project .
        CLEAR ls_method_project .

        CALL FUNCTION 'BAPI_NETWORK_MAINTAIN'
          TABLES
            i_method_project = i_method_project
            i_network        = i_network
            e_message_table  = e_message_table.

*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = 'X'.

        COMMIT WORK .

        "" append log data ..
        IF line_exists( e_message_table[ message_type = 'E' ] ).

          LOOP AT e_message_table INTO ls_message_table WHERE message_type = 'E' AND message_id = 'CN' .
            SHIFT ls_message_table-external_object_id LEFT DELETING LEADING '0' .
            ls_log-entity = |Network NO:{ ls_message_table-external_object_id }| .
            ls_log-log_text  = ls_message_table-message_text .
            ls_log-project_definition = ls_upload-project_definition .
            APPEND ls_log TO lt_log .
            CLEAR ls_log .
          ENDLOOP .

        ELSE .
          LOOP AT e_message_table INTO ls_message_table WHERE internal_object_id IS NOT INITIAL  .
            ls_map-project_definition = ls_upload-project_definition .
            ls_map-network_it = ls_message_table-internal_object_id .
            ls_map-network_ex = ls_message_table-external_object_id .
            p_conversion_ext_to_int( CHANGING p = ls_map-network_ex ).

            APPEND ls_map TO lt_map .
            CLEAR  ls_map .

            SHIFT ls_message_table-external_object_id LEFT DELETING LEADING '0' .
            SHIFT ls_message_table-internal_object_id LEFT DELETING LEADING '0' .
            ls_log-entity = |Network NO:{ ls_message_table-external_object_id }| .
            ls_log-log_text  = |Created Successfuly with number: { ls_message_table-internal_object_id }| .
            ls_log-project_definition = ls_upload-project_definition .
            APPEND ls_log TO lt_log .
            CLEAR ls_log .

          ENDLOOP .

        ENDIF .

        FREE : i_method_project , i_network , e_message_table.
        CLEAR : ls_method_project , ls_network , ls_message_table .
        net_refnumber = 0 .

      ENDAT .

      CLEAR ls_upload .
    ENDLOOP .

    WAIT UP TO 1 SECONDS .

    FREE : i_method_project , i_network , e_message_table , i_activity .
*& create activities on networks
    LOOP AT lt_upload INTO ls_upload.

*      FREE : I_METHOD_PROJECT , I_NETWORK , E_MESSAGE_TABLE , I_ACTIVITY .
      CLEAR : ls_method_project , ls_network , ls_message_table , ls_activity.

      MOVE-CORRESPONDING ls_upload TO ls_activity .
      p_conversion_ext_to_int( CHANGING p = ls_activity-cost_elem ).
      p_conversion_ext_to_int( CHANGING p = ls_activity-pur_group ).
      p_conversion_ext_to_int( CHANGING p = ls_activity-activity ).

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = ls_activity-duration_normal_unit
        IMPORTING
          output         = ls_activity-duration_normal_unit
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

*      ls_activity-duration_normal_unit_iso = ls_main_params-duration_normal_unit .
      IF line_exists( lt_map[ network_ex = ls_upload-network project_definition = ls_upload-project_definition ] ) .
        ls_activity-network = lt_map[ network_ex = ls_upload-network project_definition = ls_upload-project_definition ]-network_it .
      ENDIF .
      APPEND ls_activity TO i_activity .

      act_refnumber = act_refnumber + 1 .

      MOVE act_refnumber TO ls_method_project-refnumber.
      MOVE 'NETWORKACTIVITY' TO ls_method_project-objecttype.
      MOVE 'CREATE' TO ls_method_project-method.

      ls_method_project-objectkey = |{ ls_activity-network }{ ls_activity-activity }|.
      APPEND ls_method_project TO i_method_project.
      CLEAR  ls_method_project.

      " AT END OF NETWORK .
      ls_network-network = ls_activity-network .
*      LS_NETWORK-MRP_CONTROLLER = LS_UPLOAD-MRP_CONTROLLER .
      APPEND ls_network TO i_network .
      CLEAR  ls_network .


*      MOVE 'SAVE' TO LS_METHOD_PROJECT-METHOD .
*      APPEND LS_METHOD_PROJECT TO I_METHOD_PROJECT .
*      CLEAR  LS_METHOD_PROJECT .
*
*      FREE E_MESSAGE_TABLE .
*      CALL FUNCTION 'BAPI_NETWORK_MAINTAIN'
*        TABLES
*          I_METHOD_PROJECT = I_METHOD_PROJECT
*          I_NETWORK        = I_NETWORK
*          I_ACTIVITY       = I_ACTIVITY
*          E_MESSAGE_TABLE  = E_MESSAGE_TABLE.
*
**      COMMIT WORK  .
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = 'X'.
*
*      "" append log data ..
*      IF LINE_EXISTS( E_MESSAGE_TABLE[ MESSAGE_TYPE = 'E' ] ).
*
*        LOOP AT E_MESSAGE_TABLE INTO LS_MESSAGE_TABLE WHERE MESSAGE_TYPE = 'E' AND MESSAGE_ID = 'CN' .
*          SHIFT LS_MESSAGE_TABLE-EXTERNAL_OBJECT_ID LEFT DELETING LEADING '0' .
*          LS_LOG-ENTITY = |Network-Activity NO:{ LS_MESSAGE_TABLE-EXTERNAL_OBJECT_ID }| .
*          LS_LOG-LOG_TEXT  = LS_MESSAGE_TABLE-MESSAGE_TEXT .
*          LS_LOG-PROJECT_DEFINITION  = LS_UPLOAD-PROJECT_DEFINITION .
*          APPEND LS_LOG TO LT_LOG .
*          CLEAR LS_LOG .
*        ENDLOOP .
*
*      ENDIF .
*
      "      ENDAT .

      CLEAR : ls_upload , ls_activity .

    ENDLOOP .

    MOVE 'SAVE' TO ls_method_project-method .
    APPEND ls_method_project TO i_method_project .
    CLEAR  ls_method_project .

    FREE e_message_table .
    CALL FUNCTION 'BAPI_NETWORK_MAINTAIN'
      TABLES
        i_method_project = i_method_project
        i_network        = i_network
        i_activity       = i_activity
        e_message_table  = e_message_table.

      COMMIT WORK  .

      wait up to 1 SECONDS  .

*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = 'X'.

    "" append log data ..
    IF line_exists( e_message_table[ message_type = 'E' ] ).

      LOOP AT e_message_table INTO ls_message_table WHERE message_type = 'E' AND message_id = 'CN' .
        SHIFT ls_message_table-external_object_id LEFT DELETING LEADING '0' .
        ls_log-entity = |Network-Activity NO:{ ls_message_table-external_object_id }| .
        ls_log-log_text  = ls_message_table-message_text .
        ls_log-project_definition  = ls_upload-project_definition .
        APPEND ls_log TO lt_log .
        CLEAR ls_log .
      ENDLOOP .

    ENDIF .


**& create relationships between activities

    FREE : i_method_project , i_network , i_activity , e_message_table  .

    LOOP AT lt_relations INTO DATA(ls_rel) .

*      FREE : I_METHOD_PROJECT , I_NETWORK , I_ACTIVITY , E_MESSAGE_TABLE  .
      CLEAR : ls_method_project , ls_network , ls_message_table .

      MOVE-CORRESPONDING ls_rel TO ls_relation .
      p_conversion_ext_to_int( CHANGING p = ls_relation-network_predecessor ).
      p_conversion_ext_to_int( CHANGING p = ls_relation-network_successor ).
      p_conversion_ext_to_int( CHANGING p = ls_relation-activity_predecessor ).
      p_conversion_ext_to_int( CHANGING p = ls_relation-activity_successor ).

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = ls_relation-duration_relation_unit
        IMPORTING
          output         = ls_relation-duration_relation_unit
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      IF line_exists( lt_map[ network_ex = ls_relation-network_predecessor project_definition = ls_rel-project_definition ] ) .
        ls_relation-network_predecessor = lt_map[ network_ex = ls_relation-network_predecessor project_definition = ls_rel-project_definition ]-network_it .
      ENDIF.

      IF line_exists( lt_map[ network_ex = ls_relation-network_successor project_definition = ls_rel-project_definition  ] ) .
        ls_relation-network_successor = lt_map[ network_ex = ls_relation-network_successor project_definition = ls_rel-project_definition ]-network_it .
      ENDIF .

      APPEND ls_relation TO i_relation.

      rel_refnumber = rel_refnumber + 1  .
      MOVE rel_refnumber TO ls_method_project-refnumber.
      MOVE 'NETWORKRELATION' TO ls_method_project-objecttype.
      MOVE 'CREATE' TO ls_method_project-method.

      ls_method_project-objectkey = |{ ls_relation-relation_type }{ ls_relation-network_predecessor }{ ls_relation-activity_predecessor }{ ls_relation-network_successor }{ ls_relation-activity_successor }| .

      APPEND ls_method_project TO i_method_project .
      CLEAR  ls_method_project .

      IF ls_relation-network_predecessor = ls_relation-network_successor .

        ls_network-network = ls_relation-network_predecessor .
        APPEND ls_network TO i_network .
        CLEAR ls_network  .

      ELSE .

        ls_network-network = ls_relation-network_predecessor .
        APPEND ls_network TO i_network .
        CLEAR ls_network  .

        ls_network-network = ls_relation-network_successor .
        APPEND ls_network TO i_network .
        CLEAR : ls_network  .

      ENDIF .


      CLEAR : ls_rel  , ls_relation.
    ENDLOOP .

    MOVE 'SAVE' TO ls_method_project-method.
    APPEND ls_method_project TO i_method_project.
    CLEAR  ls_method_project.

    CALL FUNCTION 'BAPI_NETWORK_MAINTAIN'
      TABLES
        i_method_project = i_method_project
        i_network        = i_network
        i_relation       = i_relation
        e_message_table  = e_message_table.

    COMMIT WORK AND WAIT .

    "" append log data ..
    IF line_exists( e_message_table[ message_type = 'E' ] ).

      LOOP AT e_message_table INTO ls_message_table WHERE message_type = 'E' AND message_id = 'CN' .
        SHIFT ls_message_table-external_object_id LEFT DELETING LEADING '0' .
        ls_log-entity = |Relation Error| .
        ls_log-log_text  = ls_message_table-message_text .
        APPEND ls_log TO lt_log .
        CLEAR ls_log .
      ENDLOOP .

    ENDIF .




    " pass all created networks in relations
*    LOOP AT I_RELATION INTO LS_RELATION .
*
*      LS_NETWORK-NETWORK = LS_RELATION-NETWORK_PREDECESSOR .
*      APPEND LS_NETWORK TO I_NETWORK .
*      CLEAR LS_NETWORK  .
*
*      LS_NETWORK-NETWORK = LS_RELATION-NETWORK_SUCCESSOR .
*      APPEND LS_NETWORK TO I_NETWORK .
*      CLEAR : LS_NETWORK , LS_RELATION .
*
*    ENDLOOP .
*
*    DELETE ADJACENT DUPLICATES FROM I_NETWORK COMPARING NETWORK .
*
*    MOVE 'SAVE' TO LS_METHOD_PROJECT-METHOD.
*    APPEND LS_METHOD_PROJECT TO I_METHOD_PROJECT.
*    CLEAR  LS_METHOD_PROJECT.
*
*    CALL FUNCTION 'BAPI_NETWORK_MAINTAIN'
*      TABLES
*        I_METHOD_PROJECT = I_METHOD_PROJECT
*        I_NETWORK        = I_NETWORK
*        I_RELATION       = I_RELATION
*        E_MESSAGE_TABLE  = E_MESSAGE_TABLE.
*
*    COMMIT WORK AND WAIT .
*
*    "" append log data ..
*    IF LINE_EXISTS( E_MESSAGE_TABLE[ MESSAGE_TYPE = 'E' ] ).
*
*      LOOP AT E_MESSAGE_TABLE INTO LS_MESSAGE_TABLE WHERE MESSAGE_TYPE = 'E' AND MESSAGE_ID = 'CN' .
*        SHIFT LS_MESSAGE_TABLE-EXTERNAL_OBJECT_ID LEFT DELETING LEADING '0' .
*        LS_LOG-ENTITY = |Relation Error| .
*        LS_LOG-LOG_TEXT  = LS_MESSAGE_TABLE-MESSAGE_TEXT .
*        APPEND LS_LOG TO LT_LOG .
*        CLEAR LS_LOG .
*      ENDLOOP .
*
*    ENDIF .

*    FREE : i_method_project , i_network , i_activity , e_message_table .
*    CLEAR : ls_method_project , ls_network , ls_message_table .
*    refnumber = 0 .
*
*    LOOP AT lt_upload INTO ls_upload.
*
*      IF ls_upload-relation_type IS NOT INITIAL .
*        MOVE-CORRESPONDING ls_upload TO ls_relation .
*        IF line_exists( lt_map[ network_ex = ls_relation-network_predecessor ] ) .
*          ls_relation-network_predecessor = lt_map[ network_ex = ls_relation-network_predecessor ]-network_it .
*        ENDIF.
*        IF line_exists( lt_map[ network_ex = ls_relation-network_successor ] ) .
*          ls_relation-network_successor = lt_map[ network_ex = ls_relation-network_successor ]-network_it .
*        ENDIF .
*        APPEND ls_relation TO i_relation.
*        CLEAR ls_upload .
*
*        refnumber = refnumber + 1  .
*        MOVE refnumber TO ls_method_project-refnumber.
*        MOVE 'NETWORKRELATION' TO ls_method_project-objecttype.
*        MOVE 'CREATE' TO ls_method_project-method.
*
*        ls_method_project-objectkey = |{ ls_relation-relation_type }{ ls_relation-network_predecessor }{ ls_relation-activity_predecessor }{ ls_relation-network_successor }{ ls_relation-activity_successor }| .
*
*        APPEND ls_method_project TO i_method_project .
*        CLEAR  ls_method_project .
*      ENDIF .
*
*      CLEAR ls_upload .
*
*    ENDLOOP .
*
*    LOOP AT lt_map INTO ls_map .
*      ls_network-network = ls_map-network_it .
*      APPEND ls_network TO i_network .
*      CLEAR : ls_network ,ls_map .
*    ENDLOOP .
*
*    MOVE 'SAVE' TO ls_method_project-method.
*    APPEND ls_method_project TO i_method_project.
*    CLEAR  ls_method_project.
*
*    IF i_relation IS NOT INITIAL .
*      CALL FUNCTION 'BAPI_NETWORK_MAINTAIN'
*        TABLES
*          i_method_project = i_method_project
*          i_network        = i_network
*          i_relation       = i_relation
*          e_message_table  = e_message_table.
*
*      COMMIT WORK.
*
*      "" append log data ..
*      IF line_exists( e_message_table[ message_type = 'E' ] ).
*
*        LOOP AT e_message_table INTO ls_message_table WHERE message_type = 'E' AND message_id = 'CN' .
*          SHIFT ls_message_table-external_object_id LEFT DELETING LEADING '0' .
*          ls_log-entity = |Relation Error| .
*          ls_log-log_text  = ls_message_table-message_text .
*          APPEND ls_log TO lt_log .
*          CLEAR ls_log .
*        ENDLOOP .
*
*      ENDIF .
*    ENDIF .

  ENDMETHOD .
  METHOD p_conversion_ext_to_int .
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p
      IMPORTING
        output = p.
  ENDMETHOD .
  METHOD display_data .
    DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
           ls_fieldcat TYPE slis_fieldcat_alv.

    DATA :ls_layout TYPE  slis_layout_alv .

    ls_layout-zebra = 'X' .
    ls_layout-colwidth_optimize = 'X' .
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'PROJECT_DEFINITION'.
    ls_fieldcat-tabname = 'LT_LOG'.
    ls_fieldcat-seltext_m = 'Project Definition'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'ENTITY'.
    ls_fieldcat-tabname = 'LT_LOG'.
    ls_fieldcat-seltext_m = 'Entity'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'LOG_TEXT'.
    ls_fieldcat-tabname = 'LT_LOG'.
    ls_fieldcat-seltext_m = 'Information Text'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        is_layout     = ls_layout
        it_fieldcat   = lt_fieldcat
      TABLES
        t_outtab      = lt_log
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.

  ENDMETHOD .
  METHOD start .
    upload_from_template(
      EXPORTING
        p_file            = p_file1
      CHANGING
        p_table           = lt_upload
      EXCEPTIONS
        conversion_failed = 1
        OTHERS            = 2
    ).

    upload_from_template(
      EXPORTING
        p_file            = p_file2
      CHANGING
        p_table           = lt_relations
      EXCEPTIONS
        conversion_failed = 1
        OTHERS            = 2
    ).

    create_documents( ).
    display_data( ).
  ENDMETHOD .

ENDCLASS .

PARAMETERS: p_file1 TYPE rlgrap-filename DEFAULT 'C:/' OBLIGATORY, " project data
            p_file2 TYPE rlgrap-filename DEFAULT 'C:/'.   " activities relations

DATA lo_data TYPE REF TO lcl_main .
DATA lo_relation TYPE REF TO lcl_main .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file1 .
  CREATE OBJECT lo_data.
  lo_data->get_file_path(
    CHANGING
      p_file = p_file1
  ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file2 .
  CREATE OBJECT lo_relation.
  lo_relation->get_file_path(
    CHANGING
      p_file = p_file2
  ).


START-OF-SELECTION .
  lcl_main=>start( p_file1 = p_file1 p_file2 = p_file2 ).
