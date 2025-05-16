CLASS zcl_fi_soquy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    "data type range of
    DATA:
      gr_companycode TYPE RANGE OF bukrs,
      gr_glaccount   TYPE RANGE OF zde_saknr,
      gr_waers       TYPE RANGE OF waers
      .

    "data parameter
    DATA:
      lv_fromdate TYPE dats,
      lv_todate   TYPE dats,
      lv_ngaymoso TYPE dats,
      lv_inrev    TYPE zde_yesno,
      lv_opt      TYPE zde_opt_in_soctcn,
      lv_sumtk    TYPE zde_yesno.

    "table type
    DATA: gt_data TYPE TABLE OF zfi_i_soquy,
*          gt_data_pre TYPE TABLE OF zfi_i_soquy,
          gs_data LIKE LINE OF  gt_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      get_data.

ENDCLASS.



CLASS ZCL_FI_SOQUY IMPLEMENTATION.


  METHOD get_data.

    SELECT DISTINCT
    item~glaccount,
    item~postingdate,
    item~documentdate,
    item~transactioncurrency,

    item~accountingdocument,
    item~companycode,
    item~fiscalyear,
    item~ledgergllineitem,
    item~sourceledger,
    item~ledger,
    item~accountingdocumentitem,

    concat_with_space( company_address~addresseename1,
        concat_with_space( company_address~addresseename2,
            concat_with_space( company_address~addresseename3, company_address~addresseename4, 1 ) , 1 ) , 1 ) AS namecty,
    concat_with_space( company_address~streetname,
        concat_with_space( company_address~streetprefixname1,
            concat_with_space( company_address~streetprefixname2,
                concat_with_space( company_address~streetsuffixname1, company_address~streetsuffixname2, 1 ), 1 ) , 1 ) , 1 ) AS diachicty,

    i_glaccounttext~glaccountlongname,


    CASE WHEN item~debitcreditcode = 'H'
         THEN item~accountingdocument
    END  AS sochungtuchi,

    CASE WHEN item~debitcreditcode = 'S'
         THEN item~accountingdocument
    END  AS sochungtuthu,

    '          ' AS account,
    '                                                                                                    ' AS accountname,

*    CASE WHEN nnop~ma IS NOT INITIAL
*         THEN nnop~ma
*         ELSE ' '
*    END AS account,
*
*    CASE WHEN uutien1~accountingdocument IS NOT INITIAL
*         THEN uutien1~accountname1
*         WHEN uutien2~accountingdocument IS NOT INITIAL
*         THEN uutien2~accountname2
*         WHEN uutien3~accountingdocument IS NOT INITIAL
*         THEN uutien3~accountname3
*         WHEN uutien3s~accountingdocument IS NOT INITIAL
*         THEN uutien3s~accountname3s
*         ELSE ' '
*    END AS accountname,

    CASE WHEN item~documentitemtext <>  ' '
         THEN item~documentitemtext
         WHEN item~documentitemtext = ' '
         THEN journal~accountingdocumentheadertext
         ELSE ' '
    END                               AS diengiai,

    item~companycodecurrency,

    CASE WHEN item~transactioncurrency <> item~companycodecurrency
          AND item~financialaccounttype = 'S'
          AND item~debitcreditcode = 'S'
         THEN item~amountintransactioncurrency
         ELSE 0
    END AS amount_foreign_thu,


    CASE WHEN item~financialaccounttype = 'S'
          AND item~debitcreditcode = 'S'
         THEN item~amountincompanycodecurrency
         ELSE 0
    END AS amount_local_thu,



    CASE WHEN item~transactioncurrency <> item~companycodecurrency
          AND item~financialaccounttype = 'S'
          AND item~debitcreditcode = 'H'
         THEN item~amountintransactioncurrency
         ELSE 0
    END AS amount_foreign_chi,


    CASE WHEN item~financialaccounttype = 'S'
          AND item~debitcreditcode = 'H'
         THEN item~amountincompanycodecurrency
         ELSE 0
    END AS amount_local_chi,

    item~financialaccounttype,
    oadi~isnegativeposting,
    item~debitcreditcode,
    item~assignmentreference

*    tkdoiung~financialaccounttype_doiung


    FROM  i_glaccountlineitem AS item
    INNER JOIN i_journalentry AS journal
            ON item~accountingdocument = journal~accountingdocument
           AND item~companycode        = journal~companycode
           AND item~fiscalyear         = journal~fiscalyear
    INNER JOIN i_glaccounttext
            ON i_glaccounttext~glaccount = item~glaccount
           AND i_glaccounttext~language  = 'E'
    INNER JOIN i_companycode AS ccode
            ON ccode~companycode = item~companycode
    LEFT  JOIN i_operationalacctgdocitem AS oadi
            ON oadi~companycode        = item~companycode
           AND oadi~accountingdocument = item~accountingdocument
           AND oadi~fiscalyear         = item~fiscalyear
           AND CAST( oadi~accountingdocumentitem AS CHAR( 3 ) ) = substring( item~ledgergllineitem, 4, 3 )
    LEFT  JOIN zcore_i_profile_companycode_fi AS company_address
            ON ccode~addressid = company_address~addressid
*    LEFT  JOIN zfi_i_ma_nnop AS nnop
*            ON nnop~companycode        = item~companycode
*           AND nnop~accountingdocument = item~accountingdocument
*           AND nnop~fiscalyear         = item~fiscalyear
*    LEFT JOIN  zfi_i_getname_nnop_uutien1 AS uutien1
*            ON uutien1~companycode        = item~companycode
*           AND uutien1~accountingdocument = item~accountingdocument
*           AND uutien1~fiscalyear         = item~fiscalyear
*    LEFT JOIN  zfi_i_getname_nnop_uutien2 AS uutien2
*            ON uutien2~companycode        = item~companycode
*           AND uutien2~accountingdocument = item~accountingdocument
*           AND uutien2~fiscalyear         = item~fiscalyear
*    LEFT JOIN  zfi_i_getname_nnop_uutien3 AS uutien3
*            ON uutien3~companycode        = item~companycode
*           AND uutien3~accountingdocument = item~accountingdocument
*           AND uutien3~fiscalyear         = item~fiscalyear
*           AND uutien3~offsettingaccount  = item~ledgergllineitem
*    LEFT JOIN zfi_i_tkdoiung_glaccount AS tkdoiung
*           ON tkdoiung~accountingdocument  = item~accountingdocument
*           AND tkdoiung~sourceledger       = item~sourceledger
*           AND tkdoiung~companycode        = item~companycode
*           AND tkdoiung~fiscalyear         = item~fiscalyear
*           AND tkdoiung~ledger             = item~ledger
*           AND tkdoiung~ledgergllineitem   = item~ledgergllineitem
*    LEFT JOIN zfi_i_getname_nnop_uutien3_s AS uutien3s
*           ON  uutien3s~sourceledger       = item~sourceledger
*           AND uutien3s~companycode        = item~companycode
*           AND uutien3s~accountingdocument = item~accountingdocument
*           AND uutien3s~ledger             = item~ledger
*           AND tkdoiung~financialaccounttype_doiung = 'S'
    WHERE item~ledger = '0L'
    AND ( item~glaccount LIKE '111%' OR item~glaccount LIKE '112%' )
    AND (
            @lv_inrev = 'Y'
            OR (
                    @lv_inrev = 'N'
                    AND item~isreversed IS INITIAL
                    AND item~isreversal IS INITIAL
                )
          )
      AND (
            @lv_fromdate          <= item~postingdate
            AND @lv_todate        >= item~postingdate
          )
      AND  item~glaccount    IN @gr_glaccount
      AND  item~companycode  IN @gr_companycode
*      AND  item~transactioncurrency IN @gr_waers
      AND (
               ( item~transactioncurrency IN @gr_waers AND @lv_opt = 'N' )
            OR ( item~transactioncurrency IN @gr_waers AND @lv_opt = 'I' )
            OR ( item~companycodecurrency IN @gr_waers AND @lv_opt = 'T' )
          )

    ORDER BY item~glaccount, item~postingdate, item~documentdate
    INTO TABLE @DATA(gt_data_pre).
*    CHECK sy-subrc EQ 0.


    "----------- Get All Information Account Start ---------------
    "Account
    SELECT DISTINCT
     zfi_i_ma_nnop~companycode,
     zfi_i_ma_nnop~accountingdocument,
     zfi_i_ma_nnop~fiscalyear,
     data_pre~ledgergllineitem,
     zfi_i_ma_nnop~ma
     FROM zfi_i_ma_nnop
     INNER JOIN @gt_data_pre AS data_pre
             ON data_pre~companycode        = zfi_i_ma_nnop~companycode
            AND data_pre~accountingdocument = zfi_i_ma_nnop~accountingdocument
            AND data_pre~fiscalyear         = zfi_i_ma_nnop~fiscalyear
            AND data_pre~ledgergllineitem   = zfi_i_ma_nnop~offsettingledgergllineitem
     ORDER BY zfi_i_ma_nnop~companycode, zfi_i_ma_nnop~accountingdocument, zfi_i_ma_nnop~fiscalyear, data_pre~ledgergllineitem, zfi_i_ma_nnop~ma
     INTO TABLE @DATA(lt_account).
*    IF sy-subrc = 0.
*      DATA(lt_account_pre) = lt_account.
*      DELETE ADJACENT DUPLICATES FROM lt_account_pre COMPARING companycode accountingdocument fiscalyear ma.
*
*      SELECT COUNT( * ) AS count,
*          companycode,
*          accountingdocument,
*          fiscalyear
*          FROM @lt_account_pre AS data_pre
*          GROUP BY companycode, accountingdocument, fiscalyear
*          ORDER BY companycode, accountingdocument, fiscalyear
*          INTO TABLE @DATA(lt_count_account).
*
*    ENDIF.

    "Account Name
    SELECT DISTINCT
     data_pre~companycode,
     data_pre~accountingdocument,
     data_pre~fiscalyear,
     data_pre~ledgergllineitem,
     CASE WHEN uutien1~accountingdocument IS NOT INITIAL
         THEN uutien1~accountname1
         WHEN uutien2~accountingdocument IS NOT INITIAL
         THEN uutien2~accountname2
         WHEN uutien3~accountingdocument IS NOT INITIAL
         THEN uutien3~accountname3
         WHEN uutien3s~accountingdocument IS NOT INITIAL
         THEN uutien3s~accountname3s
         ELSE ' '
     END AS accountname,
     CASE WHEN uutien1~accountingdocument IS NOT INITIAL
         THEN ' '
         WHEN uutien2~accountingdocument IS NOT INITIAL
         THEN ' '
         WHEN uutien3~accountingdocument IS NOT INITIAL
         THEN 'X'
         WHEN uutien3s~accountingdocument IS NOT INITIAL
         THEN ' '
         ELSE ' '
     END AS accountnamevanglai

    FROM @gt_data_pre AS data_pre
    LEFT JOIN  zfi_i_getname_nnop_uutien1 AS uutien1
            ON uutien1~companycode        = data_pre~companycode
           AND uutien1~accountingdocument = data_pre~accountingdocument
           AND uutien1~fiscalyear         = data_pre~fiscalyear
           AND uutien1~offsettingledgergllineitem  = data_pre~ledgergllineitem
    LEFT JOIN  zfi_i_getname_nnop_uutien2 AS uutien2
            ON uutien2~companycode        = data_pre~companycode
           AND uutien2~accountingdocument = data_pre~accountingdocument
           AND uutien2~fiscalyear         = data_pre~fiscalyear
           AND uutien2~offsettingledgergllineitem = data_pre~ledgergllineitem
    LEFT JOIN  zfi_i_getname_nnop_uutien3 AS uutien3
            ON uutien3~companycode        = data_pre~companycode
           AND uutien3~accountingdocument = data_pre~accountingdocument
           AND uutien3~fiscalyear         = data_pre~fiscalyear
           AND uutien3~offsettingledgergllineitem  = data_pre~ledgergllineitem
    LEFT JOIN zfi_i_tkdoiung_glaccount AS tkdoiung
           ON tkdoiung~accountingdocument  = data_pre~accountingdocument
           AND tkdoiung~sourceledger       = data_pre~sourceledger
           AND tkdoiung~companycode        = data_pre~companycode
           AND tkdoiung~fiscalyear         = data_pre~fiscalyear
           AND tkdoiung~ledger             = data_pre~ledger
           AND tkdoiung~ledgergllineitem   = data_pre~ledgergllineitem
    LEFT JOIN zfi_i_getname_nnop_uutien3_s AS uutien3s
           ON  uutien3s~sourceledger       = data_pre~sourceledger
           AND uutien3s~companycode        = data_pre~companycode
           AND uutien3s~accountingdocument = data_pre~accountingdocument
           AND uutien3s~ledger             = data_pre~ledger
           AND uutien3s~ledgergllineitem   = data_pre~ledgergllineitem
           AND tkdoiung~financialaccounttype_doiung = 'S'
     ORDER BY data_pre~companycode, data_pre~accountingdocument, data_pre~fiscalyear, data_pre~ledgergllineitem
     INTO TABLE @DATA(lt_accountname).
    IF sy-subrc = 0.
      DELETE lt_accountname  WHERE accountname = ' '.
      DATA(lt_account_pre) = lt_accountname.
      DELETE ADJACENT DUPLICATES FROM lt_account_pre COMPARING companycode accountingdocument fiscalyear accountname.

      SELECT COUNT( * ) AS count,
          companycode,
          accountingdocument,
          fiscalyear
          FROM @lt_account_pre AS data_pre
          GROUP BY companycode, accountingdocument, fiscalyear
          ORDER BY companycode, accountingdocument, fiscalyear
          INTO TABLE @DATA(lt_count_account).

      "T/H Vãng Lai loại S nhưng ko có line loại D,K đối ứng. Logic sẽ lấy line loại D,K của 1 dòng bất kỳ nếu chứng từ đó chỉ có 1 account. Ngược lại để trống
      SELECT DISTINCT
      count_account~companycode,
      count_account~accountingdocument,
      count_account~fiscalyear,
      uutien3s~accountname3s
      FROM @lt_count_account AS count_account
      INNER JOIN zfi_i_getname_nnop_uutien3_s AS uutien3s
              ON uutien3s~companycode        = count_account~companycode
             AND uutien3s~accountingdocument = count_account~accountingdocument
             AND uutien3s~fiscalyear         = count_account~fiscalyear
      WHERE count_account~count > 1
      ORDER BY count_account~companycode, count_account~accountingdocument, count_account~fiscalyear
      INTO TABLE @DATA(lt_accountnamevanglai).

    ENDIF.

    "----------- Get All Information Account End ---------------
    DATA: lv_flag_account     TYPE c LENGTH 1,
          lv_ledgergllineitem TYPE c LENGTH 6,
          lv_count_account    TYPE n LENGTH 2,
          lv_vanglai          TYPE c LENGTH 1.

    LOOP AT gt_data_pre REFERENCE INTO DATA(lr_data_pre).

      "Account
      READ TABLE lt_account REFERENCE INTO DATA(lr_account)
        WITH KEY companycode        = lr_data_pre->companycode
                 accountingdocument = lr_data_pre->accountingdocument
                 fiscalyear         = lr_data_pre->fiscalyear
                 ledgergllineitem   = lr_data_pre->ledgergllineitem
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lr_data_pre->account = lr_account->ma.
        lv_flag_account = 'X'.
      ENDIF.

      "Account Name
      READ TABLE lt_accountname REFERENCE INTO DATA(lr_accountname)
        WITH KEY companycode        = lr_data_pre->companycode
                 accountingdocument = lr_data_pre->accountingdocument
                 fiscalyear         = lr_data_pre->fiscalyear
                 ledgergllineitem   = lr_data_pre->ledgergllineitem
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lr_data_pre->accountname = lr_accountname->accountname.
      ENDIF.

      "T/H Line loại S nhưng ko có line loại D,K đối ứng. Logic sẽ lấy line loại D,K của 1 dòng bất kỳ nếu chứng từ đó chỉ có 1 account. Ngược lại để trống
      IF lv_flag_account IS INITIAL.
        READ TABLE lt_count_account REFERENCE INTO DATA(lr_count_account)
            WITH KEY companycode = lr_data_pre->companycode
                     accountingdocument  = lr_data_pre->accountingdocument
                     fiscalyear  = lr_data_pre->fiscalyear
                     BINARY SEARCH.
        IF sy-subrc = 0.
          lv_count_account = lr_count_account->count.
        ENDIF.

        IF lv_count_account = 1.
          "Account
          READ TABLE lt_account REFERENCE INTO lr_account
            WITH KEY companycode        = lr_data_pre->companycode
                     accountingdocument = lr_data_pre->accountingdocument
                     fiscalyear         = lr_data_pre->fiscalyear
*                     ledgergllineitem   = lr_data_pre->ledgergllineitem
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lr_data_pre->account = lr_account->ma.
            lv_ledgergllineitem  = lr_account->ledgergllineitem.
          ENDIF.

          "Account Name
          READ TABLE lt_accountname REFERENCE INTO lr_accountname
            WITH KEY companycode        = lr_data_pre->companycode
                     accountingdocument = lr_data_pre->accountingdocument
                     fiscalyear         = lr_data_pre->fiscalyear
                     ledgergllineitem   = lv_ledgergllineitem
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lr_data_pre->accountname = lr_accountname->accountname.
          ENDIF.

        ELSEIF lv_count_account > 1.
          "T/h Mã Vãng Lai
          " Check Account exist Mã Vãng Lai ???
          READ TABLE lt_accountname REFERENCE INTO lr_accountname
            WITH KEY companycode        = lr_data_pre->companycode
                     accountingdocument = lr_data_pre->accountingdocument
                     fiscalyear         = lr_data_pre->fiscalyear
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lv_vanglai = lr_accountname->accountnamevanglai.
          ENDIF.

          IF lv_vanglai = 'X'.
            "Account
            READ TABLE lt_account REFERENCE INTO lr_account
              WITH KEY companycode        = lr_data_pre->companycode
                       accountingdocument = lr_data_pre->accountingdocument
                       fiscalyear         = lr_data_pre->fiscalyear
*                     ledgergllineitem   = lr_data_pre->ledgergllineitem
                       BINARY SEARCH.
            IF sy-subrc = 0.
              lr_data_pre->account = lr_account->ma.
            ENDIF.

            "Account Name
            READ TABLE lt_accountnamevanglai REFERENCE INTO DATA(lr_accountnamevanglai)
              WITH KEY companycode        = lr_data_pre->companycode
                       accountingdocument = lr_data_pre->accountingdocument
                       fiscalyear         = lr_data_pre->fiscalyear
*                     ledgergllineitem   = lr_data_pre->ledgergllineitem
                       BINARY SEARCH.
            IF sy-subrc = 0.
              lr_data_pre->accountname = lr_accountnamevanglai->accountname3s.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

      CLEAR: lv_flag_account, lv_count_account, lv_ledgergllineitem, lv_vanglai.

    ENDLOOP.

    "---------------------------------


    "XỬ LÝ TỒN ĐẦU KỲ
    DATA: ls_data_pre  LIKE LINE OF gt_data_pre,
          lr_glaccount TYPE RANGE OF saknr.

    SELECT DISTINCT
      'I' AS sign,
      'EQ' AS option,
      glaccount AS low
      FROM @gt_data_pre AS data
      WHERE glaccount IS NOT INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @lr_glaccount.

    IF lv_opt = 'N'.

      "Ngoại tệ
      SELECT
      item~companycode,
*      item~fiscalyear,
      item~glaccount,
      item~companycodecurrency,
      item~transactioncurrency,
      SUM( item~amountintransactioncurrency ) AS sumdudaukitransactioncurr,
      SUM( item~amountincompanycodecurrency ) AS sumdudaukicompanycodecurr
      FROM i_glaccountlineitem AS item
      INNER JOIN i_journalentry AS journal
            ON item~accountingdocument = journal~accountingdocument
           AND item~companycode        = journal~companycode
           AND item~fiscalyear         = journal~fiscalyear
      LEFT  JOIN i_operationalacctgdocitem AS oadi
            ON oadi~companycode        = item~companycode
           AND oadi~accountingdocument = item~accountingdocument
           AND oadi~fiscalyear         = item~fiscalyear
           AND CAST( oadi~accountingdocumentitem AS CHAR( 3 ) ) = substring( item~ledgergllineitem, 4, 3 )

      WHERE item~ledger = '0L'
        AND ( item~glaccount LIKE '111%' OR item~glaccount LIKE '112%' )
        AND  item~glaccount    IN @gr_glaccount
        AND item~specialglcode IN ( '', 'A' )
        AND item~postingdate < @lv_fromdate
        AND ( item~clearingdate IS INITIAL OR
            item~clearingdate >= @lv_fromdate )
        AND (
                    @lv_inrev = 'Y'
                OR (
                         @lv_inrev = 'N'
                     AND item~isreversed IS INITIAL
                     AND item~isreversal IS INITIAL
                   )
            )
        AND  item~companycode  IN @gr_companycode
        AND  item~transactioncurrency IN @gr_waers
        AND item~accountingdocumenttype IS NOT INITIAL
*      AND item~AccountingDocumentCategory <> 'C'
*       AND item~accountingdocumenttype IS NOT INITIAL
*        AND (
*               ( item~transactioncurrency IN @gr_waers AND @lv_opt = 'N' )
*            OR ( item~companycodecurrency IN @gr_waers AND @lv_opt = 'I' )
*          )
      GROUP BY item~companycode, item~glaccount, item~companycodecurrency, item~transactioncurrency " item~fiscalyear,
      ORDER BY item~companycode, item~glaccount, item~companycodecurrency, item~transactioncurrency " item~fiscalyear,
      INTO TABLE @DATA(lt_daukyngoaite).
      IF sy-subrc = 0.
        DELETE lt_daukyngoaite WHERE sumdudaukitransactioncurr = 0 AND sumdudaukicompanycodecurr = 0.

        DATA(lt_addglaccountngoaite) = lt_daukyngoaite.

        IF lr_glaccount IS NOT INITIAL.
          DELETE lt_addglaccountngoaite WHERE glaccount IN lr_glaccount.
        ENDIF.


        SELECT DISTINCT
        gla_text~glaccount,
        gla_text~glaccountlongname
        FROM @lt_addglaccountngoaite AS addacc
        LEFT JOIN i_glaccounttext AS gla_text
               ON gla_text~glaccount = addacc~glaccount
              AND gla_text~language  = 'E'
        ORDER BY gla_text~glaccount
        INTO TABLE @DATA(lt_glaccountname).

        LOOP AT lt_addglaccountngoaite INTO DATA(ls_addglaccountngoaite).

          MOVE-CORRESPONDING ls_addglaccountngoaite TO ls_data_pre.
          READ TABLE lt_glaccountname INTO DATA(ls_glaccountname)
            WITH KEY glaccount = ls_addglaccountngoaite-glaccount
                     BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data_pre-glaccountlongname = ls_glaccountname-glaccountlongname.
          ENDIF.

          APPEND ls_data_pre TO gt_data_pre.

        ENDLOOP.

      ENDIF.


    ELSEIF lv_opt = 'I' OR lv_opt = 'T'.

      "Nội tệ //
      SELECT
      item~companycode,
*      item~fiscalyear,
      item~glaccount,
      item~companycodecurrency,
      SUM( item~amountincompanycodecurrency ) AS sumdudaukicompanycodecurr
      FROM i_glaccountlineitem AS item
      INNER JOIN i_journalentry AS journal
            ON item~accountingdocument = journal~accountingdocument
           AND item~companycode        = journal~companycode
           AND item~fiscalyear         = journal~fiscalyear
      LEFT  JOIN i_operationalacctgdocitem AS oadi
            ON oadi~companycode        = item~companycode
           AND oadi~accountingdocument = item~accountingdocument
           AND oadi~fiscalyear         = item~fiscalyear
           AND CAST( oadi~accountingdocumentitem AS CHAR( 3 ) ) = substring( item~ledgergllineitem, 4, 3 )

      WHERE item~ledger = '0L'
        AND ( item~glaccount LIKE '111%' OR item~glaccount LIKE '112%' )
        AND  item~glaccount    IN @gr_glaccount
        AND item~specialglcode IN ( '', 'A' )
        AND item~postingdate < @lv_fromdate
        AND ( item~clearingdate IS INITIAL OR
            item~clearingdate >= @lv_fromdate )
        AND (
                    @lv_inrev = 'Y'
                OR (
                         @lv_inrev = 'N'
                     AND item~isreversed IS INITIAL
                     AND item~isreversal IS INITIAL
                   )
            )
        AND  item~companycode  IN @gr_companycode
*        AND  item~transactioncurrency IN @gr_waers
     AND (
               ( item~transactioncurrency IN @gr_waers AND @lv_opt = 'N' )
            OR ( item~transactioncurrency IN @gr_waers AND @lv_opt = 'I' )
            OR ( item~companycodecurrency IN @gr_waers AND @lv_opt = 'T' )
          )
*      AND item~AccountingDocumentCategory <> 'C'
*      AND item~accountingdocumenttype IS NOT INITIAL
      GROUP BY item~companycode, item~glaccount, item~companycodecurrency "item~fiscalyear,
      ORDER BY item~companycode, item~glaccount, item~companycodecurrency "item~fiscalyear,
      INTO TABLE @DATA(lt_daukynoite).
      IF sy-subrc = 0.
        DELETE lt_daukynoite WHERE sumdudaukicompanycodecurr = 0.

        DATA(lt_addglaccountnoite) = lt_daukynoite.
        IF lr_glaccount IS NOT INITIAL.
          DELETE lt_addglaccountnoite WHERE glaccount IN lr_glaccount.
        ENDIF.

        SELECT DISTINCT
        gla_text~glaccount,
        gla_text~glaccountlongname
        FROM @lt_addglaccountnoite AS addacc
        LEFT JOIN i_glaccounttext AS gla_text
               ON gla_text~glaccount = addacc~glaccount
              AND gla_text~language  = 'E'
        ORDER BY gla_text~glaccount
        INTO TABLE @lt_glaccountname.

        LOOP AT lt_addglaccountnoite INTO DATA(ls_addglaccountnoite).
          MOVE-CORRESPONDING ls_addglaccountnoite TO ls_data_pre.
          READ TABLE lt_glaccountname INTO ls_glaccountname
            WITH KEY glaccount = ls_addglaccountnoite-glaccount
                     BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data_pre-glaccountlongname = ls_glaccountname-glaccountlongname.
          ENDIF.
          APPEND ls_data_pre TO gt_data_pre.
        ENDLOOP.
      ENDIF.
    ENDIF.

    "============================<< Option Sum >>=================================
    IF lv_sumtk = 'Y'. "option sum tài khoản

      SELECT
      glaccount,
      postingdate,
      documentdate,
      accountingdocument,
      assignmentreference,
      accountname,
      account,
      diengiai,
      transactioncurrency,
      SUM( amount_local_chi )   AS amount_local_chi,
      SUM( amount_foreign_chi ) AS amount_foreign_chi,
      SUM( amount_local_thu )   AS amount_local_thu,
      SUM( amount_foreign_thu ) AS amount_foreign_thu
      FROM @gt_data_pre AS data
      GROUP BY glaccount, postingdate, documentdate, accountingdocument, assignmentreference, accountname, account, diengiai, transactioncurrency
      ORDER BY glaccount, postingdate, documentdate, accountingdocument, assignmentreference, accountname, account, diengiai, transactioncurrency
      INTO TABLE @DATA(lt_datasum).

      SORT gt_data_pre BY glaccount postingdate documentdate accountingdocument assignmentreference accountname account diengiai transactioncurrency.
      DELETE ADJACENT DUPLICATES FROM gt_data_pre COMPARING glaccount postingdate documentdate accountingdocument assignmentreference accountname account diengiai transactioncurrency.

      LOOP AT gt_data_pre REFERENCE INTO DATA(gs_data_pre).
        READ TABLE lt_datasum INTO DATA(ls_datasum)
            WITH KEY glaccount            = gs_data_pre->glaccount
                     postingdate          = gs_data_pre->postingdate
                     documentdate         = gs_data_pre->documentdate
                     accountingdocument   = gs_data_pre->accountingdocument
                     assignmentreference  = gs_data_pre->assignmentreference
                     accountname          = gs_data_pre->accountname
                     account              = gs_data_pre->account
                     diengiai             = gs_data_pre->diengiai
                     transactioncurrency  = gs_data_pre->transactioncurrency
                     BINARY SEARCH.
        IF sy-subrc = 0.
          gs_data_pre->amount_local_chi   = ls_datasum-amount_local_chi.
          gs_data_pre->amount_foreign_chi = ls_datasum-amount_foreign_chi.
          gs_data_pre->amount_local_thu   = ls_datasum-amount_local_thu.
          gs_data_pre->amount_foreign_thu = ls_datasum-amount_foreign_thu.
        ENDIF.
      ENDLOOP.
    ENDIF.



    DATA:
      "VND
      lw_subtotal_tondauky_vnd      TYPE zde_amount,
      lw_subtotal_phatsinhthu_vnd   TYPE zde_amount,
      lw_subtotal_phatsinhchi_vnd   TYPE zde_amount,
      lw_subtotal_toncuoiky_vnd     TYPE zde_amount,

      lw_total_tondauky_vnd         TYPE zde_amount,
      lw_total_phatsinhthu_vnd      TYPE zde_amount,
      lw_total_phatsinhchi_vnd      TYPE zde_amount,
      lw_total_toncuoiky_vnd        TYPE zde_amount,


      "USD
      lw_subtotal_tondauky_usd      TYPE zde_amount,
      lw_subtotal_phatsinhthu_usd   TYPE zde_amount,
      lw_subtotal_phatsinhchi_usd   TYPE zde_amount,
      lw_subtotal_toncuoiky_usd     TYPE zde_amount,

      lw_subtotal_tondauky_usd_c    TYPE zde_amount,
      lw_subtotal_phatsinhthu_usd_c TYPE zde_amount,
      lw_subtotal_phatsinhchi_usd_c TYPE zde_amount,
      lw_subtotal_toncuoiky_usd_c   TYPE zde_amount,

      lw_total_tondauky_usd         TYPE zde_amount,
      lw_total_phatsinhthu_usd      TYPE zde_amount,
      lw_total_phatsinhchi_usd      TYPE zde_amount,
      lw_total_toncuoiky_usd        TYPE zde_amount,

      lw_total_tondauky_usd_c       TYPE zde_amount,
      lw_total_phatsinhthu_usd_c    TYPE zde_amount,
      lw_total_phatsinhchi_usd_c    TYPE zde_amount,
      lw_total_toncuoiky_usd_c      TYPE zde_amount,


      "EUR
      lw_subtotal_tondauky_eur      TYPE zde_amount,
      lw_subtotal_phatsinhthu_eur   TYPE zde_amount,
      lw_subtotal_phatsinhchi_eur   TYPE zde_amount,
      lw_subtotal_toncuoiky_eur     TYPE zde_amount,

      lw_subtotal_tondauky_eur_c    TYPE zde_amount,
      lw_subtotal_phatsinhthu_eur_c TYPE zde_amount,
      lw_subtotal_phatsinhchi_eur_c TYPE zde_amount,
      lw_subtotal_toncuoiky_eur_c   TYPE zde_amount,

      lw_total_tondauky_eur         TYPE zde_amount,
      lw_total_phatsinhthu_eur      TYPE zde_amount,
      lw_total_phatsinhchi_eur      TYPE zde_amount,
      lw_total_toncuoiky_eur        TYPE zde_amount,

      lw_total_tondauky_eur_c       TYPE zde_amount,
      lw_total_phatsinhthu_eur_c    TYPE zde_amount,
      lw_total_phatsinhchi_eur_c    TYPE zde_amount,
      lw_total_toncuoiky_eur_c      TYPE zde_amount,


      lw_ton_vnd                    TYPE zde_amount VALUE 0,
      lw_ton_usd                    TYPE zde_amount VALUE 0,
      lw_ton_usd_c                  TYPE zde_amount VALUE 0,
      lw_ton_eur                    TYPE zde_amount VALUE 0,
      lw_ton_eur_c                  TYPE zde_amount VALUE 0,

      lw_namecty                    TYPE c LENGTH 100,
      lw_diachicty                  TYPE c LENGTH 100.


    DATA: is_lastline   TYPE c LENGTH 1.

    SORT gt_data_pre BY glaccount postingdate accountingdocument transactioncurrency.

    LOOP AT gt_data_pre ASSIGNING FIELD-SYMBOL(<ls_data_pre>).
      CLEAR: is_lastline.

      IF lw_namecty IS INITIAL.
        lw_namecty = <ls_data_pre>-namecty.
      ENDIF.

      IF lw_diachicty IS INITIAL.
        lw_diachicty = <ls_data_pre>-diachicty.
      ENDIF.

      MOVE-CORRESPONDING <ls_data_pre> TO gs_data.

      " bổ sung tên công ty và địa chỉ cho all data
      gs_data-namecty   = lw_namecty.
      gs_data-diachicty = lw_diachicty.


      gs_data-amount_local_chi   *= -1.
      gs_data-amount_foreign_chi *= -1.


*      "Account
*      READ TABLE lt_account REFERENCE INTO DATA(lr_account)
*        WITH KEY companycode = gs_data-companycode
*                 accountingdocument = gs_data-accountingdocument
*                 fiscalyear = gs_data-fiscalyear
*                 ledgergllineitem = gs_data-ledgergllineitem
*                 BINARY SEARCH.
*      IF sy-subrc = 0.
*        gs_data-account = lr_account->ma.
*      ENDIF.
*
*      "Account Name
*      READ TABLE lt_accountname REFERENCE INTO DATA(lr_accountname)
*        WITH KEY companycode = gs_data-companycode
*                 accountingdocument = gs_data-accountingdocument
*                 fiscalyear = gs_data-fiscalyear
*                 ledgergllineitem = gs_data-ledgergllineitem
*                 BINARY SEARCH.
*      IF sy-subrc = 0.
*        gs_data-accountname = lr_accountname->accountname.
*      ENDIF.

*      IF gs_data-isnegativeposting = 'X'.
*        gs_data-amount_local_chi   *= -1.
*        gs_data-amount_foreign_chi *= -1.
*        gs_data-amount_local_thu   *= -1.
*        gs_data-amount_foreign_thu *= -1.
*      ENDIF.


      IF lv_opt = 'I' OR lv_opt = 'T'. " NỘI TỆ
        "tồn
        IF lw_ton_vnd IS INITIAL.
          "VND Tồn Đầu Kỳ
          READ TABLE lt_daukynoite INTO DATA(ls_daukynoite)
            WITH KEY companycode    = gs_data-companycode
*                     fiscalyear     = gs_data-fiscalyear
                     glaccount      = gs_data-glaccount
                     companycodecurrency = 'VND'
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lw_ton_vnd = ls_daukynoite-sumdudaukicompanycodecurr.
          ENDIF.
        ENDIF.

        "vnd
        lw_subtotal_phatsinhthu_vnd  += gs_data-amount_local_thu.
        lw_subtotal_phatsinhchi_vnd  += gs_data-amount_local_chi.
        lw_total_phatsinhthu_vnd     += gs_data-amount_local_thu.
        lw_total_phatsinhchi_vnd     += gs_data-amount_local_chi.


        gs_data-amount_local_ton = lw_ton_vnd + gs_data-amount_local_thu - gs_data-amount_local_chi.
        lw_ton_vnd = gs_data-amount_local_ton.

      ELSEIF lv_opt = 'N'.
        IF gs_data-transactioncurrency  = 'USD'.
          IF lw_ton_usd IS INITIAL AND lw_ton_usd_c IS INITIAL.
            "USD Tồn Đầu Kỳ
            READ TABLE lt_daukyngoaite INTO DATA(ls_daukyngoaite)
              WITH KEY companycode    = gs_data-companycode
*                       fiscalyear     = gs_data-fiscalyear
                       glaccount      = gs_data-glaccount
                       transactioncurrency = 'USD'
                       BINARY SEARCH.
            IF sy-subrc = 0.
              "transactioncode USD
              lw_ton_usd = ls_daukyngoaite-sumdudaukitransactioncurr.

              "companycode USD
              lw_ton_usd_c = ls_daukyngoaite-sumdudaukicompanycodecurr.
            ENDIF.
          ENDIF.

          "usd
          lw_subtotal_phatsinhthu_usd  += gs_data-amount_foreign_thu.
          lw_subtotal_phatsinhchi_usd  += gs_data-amount_foreign_chi.
          lw_total_phatsinhthu_usd     += gs_data-amount_foreign_thu.
          lw_total_phatsinhchi_usd     += gs_data-amount_foreign_chi.

          "tồn
          gs_data-amount_foreign_ton = lw_ton_usd + gs_data-amount_foreign_thu - gs_data-amount_foreign_chi.
          lw_ton_usd = gs_data-amount_foreign_ton.

          "vnd
          lw_subtotal_phatsinhthu_usd_c  += gs_data-amount_local_thu.
          lw_subtotal_phatsinhchi_usd_c  += gs_data-amount_local_chi.
          lw_total_phatsinhthu_usd_c     += gs_data-amount_local_thu.
          lw_total_phatsinhchi_usd_c     += gs_data-amount_local_chi.

          "tồn
          gs_data-amount_local_ton = lw_ton_usd_c + gs_data-amount_local_thu - gs_data-amount_local_chi.
          lw_ton_usd_c = gs_data-amount_local_ton.
        ENDIF.

        IF gs_data-transactioncurrency  = 'EUR'.
          IF lw_ton_eur IS INITIAL AND lw_ton_eur_c IS INITIAL.
            "EUR Tồn Đầu Kỳ
            READ TABLE lt_daukyngoaite INTO ls_daukyngoaite
              WITH KEY companycode    = gs_data-companycode
*                       fiscalyear     = gs_data-fiscalyear
                       glaccount      = gs_data-glaccount
                       transactioncurrency = 'EUR'
                       BINARY SEARCH.
            IF sy-subrc = 0.
              "transactioncode EUR
              lw_ton_eur = ls_daukyngoaite-sumdudaukitransactioncurr.

              "companycode EUR
              lw_ton_eur_c = ls_daukyngoaite-sumdudaukicompanycodecurr.
            ENDIF.
          ENDIF.

          "eur
          lw_subtotal_phatsinhthu_eur  += gs_data-amount_foreign_thu.
          lw_subtotal_phatsinhchi_eur  += gs_data-amount_foreign_chi.
          lw_total_phatsinhthu_eur     += gs_data-amount_foreign_thu.
          lw_total_phatsinhchi_eur     += gs_data-amount_foreign_chi.

          "tồn
          gs_data-amount_foreign_ton = lw_ton_eur + gs_data-amount_foreign_thu - gs_data-amount_foreign_chi.
          lw_ton_eur = gs_data-amount_foreign_ton.

          "vnd
          lw_subtotal_phatsinhthu_eur_c  += gs_data-amount_local_thu.
          lw_subtotal_phatsinhchi_eur_c  += gs_data-amount_local_chi.
          lw_total_phatsinhthu_eur_c     += gs_data-amount_local_thu.
          lw_total_phatsinhchi_eur_c     += gs_data-amount_local_chi.

          "tồn
          gs_data-amount_local_ton = lw_ton_eur_c + gs_data-amount_local_thu - gs_data-amount_local_chi.
          lw_ton_eur_c = gs_data-amount_local_ton.
        ENDIF.
      ENDIF.

      "items
      IF gs_data-accountingdocument IS NOT INITIAL. "check TH add account có tồn đầu kỳ mà ko phát sinh trong kỳ
        gs_data-islevel = '0'.
        APPEND gs_data TO gt_data.
      ENDIF.


      "Because using CONTINUE => AT LAST BEFORE AT END OF
      AT LAST.
        is_lastline = 'X'.
      ENDAT.



      AT END OF glaccount.
        "------------------------------Start Xử Lý ---------------------------------------
        IF lv_opt = 'I' OR lv_opt = 'T'. " Nội tệ
          "VND Tồn Đầu Kỳ
          READ TABLE lt_daukynoite INTO ls_daukynoite
            WITH KEY companycode    = gs_data-companycode
*                     fiscalyear     = gs_data-fiscalyear
                     glaccount      = gs_data-glaccount
                     companycodecurrency = 'VND'
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lw_subtotal_tondauky_vnd = ls_daukynoite-sumdudaukicompanycodecurr.
            lw_total_tondauky_vnd   += ls_daukynoite-sumdudaukicompanycodecurr.
          ENDIF.

          "VND Tồn Cuối Kỳ 23A = 20A + 21A - 22A
          lw_subtotal_toncuoiky_vnd = lw_subtotal_tondauky_vnd + lw_subtotal_phatsinhthu_vnd - lw_subtotal_phatsinhchi_vnd.
          lw_total_toncuoiky_vnd   += lw_subtotal_toncuoiky_vnd.

        ELSEIF lv_opt = 'N'.
          "-----------------USD------------------
          "USD Tồn Đầu Kỳ
          READ TABLE lt_daukyngoaite INTO ls_daukyngoaite
            WITH KEY companycode    = gs_data-companycode
*                     fiscalyear     = gs_data-fiscalyear
                     glaccount      = gs_data-glaccount
                     transactioncurrency = 'USD'
                     BINARY SEARCH.
          IF sy-subrc = 0.
            "transactioncode USD
            lw_subtotal_tondauky_usd = ls_daukyngoaite-sumdudaukitransactioncurr.
            lw_total_tondauky_usd   += ls_daukyngoaite-sumdudaukitransactioncurr.

            "companycode USD
            lw_subtotal_tondauky_usd_c = ls_daukyngoaite-sumdudaukicompanycodecurr.
            lw_total_tondauky_usd_c   += ls_daukyngoaite-sumdudaukicompanycodecurr.
          ENDIF.

          "transactioncode USD Tồn Cuối Kỳ 23B = 20B + 21B - 22B
          lw_subtotal_toncuoiky_usd = lw_subtotal_tondauky_usd + lw_subtotal_phatsinhthu_usd - lw_subtotal_phatsinhchi_usd.
          lw_total_toncuoiky_usd   += lw_subtotal_toncuoiky_usd.

          "companycode USD Tồn Cuối Kỳ 23A = 20A + 21A - 22A
          lw_subtotal_toncuoiky_usd_c = lw_subtotal_tondauky_usd_c + lw_subtotal_phatsinhthu_usd_c - lw_subtotal_phatsinhchi_usd_c.
          lw_total_toncuoiky_usd_c   += lw_subtotal_toncuoiky_usd_c.

          "-----------------USD------------------


          "-----------------EUR------------------
          "EUR Tồn Đầu Kỳ
          READ TABLE lt_daukyngoaite INTO ls_daukyngoaite
            WITH KEY companycode    = gs_data-companycode
*                     fiscalyear     = gs_data-fiscalyear
                     glaccount      = gs_data-glaccount
                     transactioncurrency = 'EUR'
                     BINARY SEARCH.
          IF sy-subrc = 0.
            "transactioncode EUR
            lw_subtotal_tondauky_eur = ls_daukyngoaite-sumdudaukitransactioncurr.
            lw_total_tondauky_eur   += ls_daukyngoaite-sumdudaukitransactioncurr.

            "companycode EUR
            lw_subtotal_tondauky_eur_c = ls_daukyngoaite-sumdudaukicompanycodecurr.
            lw_total_tondauky_eur_c   += ls_daukyngoaite-sumdudaukicompanycodecurr.
          ENDIF.

          "transactioncode EUR Tồn Cuối Kỳ 23B = 20B + 21B - 22B
          lw_subtotal_toncuoiky_eur = lw_subtotal_tondauky_eur + lw_subtotal_phatsinhthu_eur - lw_subtotal_phatsinhchi_eur.
          lw_total_toncuoiky_eur   += lw_subtotal_toncuoiky_eur.

          "companycode EUR Tồn Cuối Kỳ 23A = 20A + 21A - 22A
          lw_subtotal_toncuoiky_eur_c = lw_subtotal_tondauky_eur_c + lw_subtotal_phatsinhthu_eur_c - lw_subtotal_phatsinhchi_eur_c.
          lw_total_toncuoiky_eur_c   += lw_subtotal_toncuoiky_eur_c.

          "-----------------EUR------------------

        ENDIF.
        "------------------------------End Xử Lý ---------------------------------------

        "---------------------------Start append data subtotal--------------------------------
        gs_data-islevel = '1'.

        IF lv_opt = 'I' OR lv_opt = 'T'.     " Nội tệ
          "----VND---
          gs_data-tondauky_vnd     = lw_subtotal_tondauky_vnd.
          gs_data-phatsinhchi_vnd  = lw_subtotal_phatsinhchi_vnd.
          gs_data-phatsinhthu_vnd  = lw_subtotal_phatsinhthu_vnd.
          gs_data-toncuoiky_vnd    = lw_subtotal_toncuoiky_vnd.

        ELSEIF lv_opt = 'N'. " Ngoại tệ
          "------------USD----------
          gs_data-tondauky_usd     = lw_subtotal_tondauky_usd.
          gs_data-phatsinhchi_usd  = lw_subtotal_phatsinhchi_usd.
          gs_data-phatsinhthu_usd  = lw_subtotal_phatsinhthu_usd.
          gs_data-toncuoiky_usd    = lw_subtotal_toncuoiky_usd.

          "Company Code USD
          gs_data-tondauky_companycode_usd     = lw_subtotal_tondauky_usd_c.
          gs_data-phatsinhchi_companycode_usd  = lw_subtotal_phatsinhchi_usd_c.
          gs_data-phatsinhthu_companycode_usd  = lw_subtotal_phatsinhthu_usd_c.
          gs_data-toncuoiky_companycode_usd    = lw_subtotal_toncuoiky_usd_c.
          "------------USD----------


          "------------EUR----------
          gs_data-tondauky_eur     = lw_subtotal_tondauky_eur.
          gs_data-phatsinhchi_eur  = lw_subtotal_phatsinhchi_eur.
          gs_data-phatsinhthu_eur  = lw_subtotal_phatsinhthu_eur.
          gs_data-toncuoiky_eur    = lw_subtotal_toncuoiky_eur.

          "Company Code EUR
          gs_data-tondauky_companycode_eur     = lw_subtotal_tondauky_eur_c.
          gs_data-phatsinhchi_companycode_eur  = lw_subtotal_phatsinhchi_eur_c.
          gs_data-phatsinhthu_companycode_eur  = lw_subtotal_phatsinhthu_eur_c.
          gs_data-toncuoiky_companycode_eur    = lw_subtotal_toncuoiky_eur_c.
          "------------EUR----------
        ENDIF.

        APPEND gs_data TO gt_data.
        "---------------------------End append data subtotal--------------------------------

        CLEAR:
        "VND
        lw_subtotal_tondauky_vnd      ,
        lw_subtotal_phatsinhthu_vnd   ,
        lw_subtotal_phatsinhchi_vnd   ,
        lw_subtotal_toncuoiky_vnd     ,
        gs_data-tondauky_vnd          ,
        gs_data-phatsinhchi_vnd       ,
        gs_data-phatsinhthu_vnd       ,
        gs_data-toncuoiky_vnd         ,

        "USD
        lw_subtotal_tondauky_usd      ,
        lw_subtotal_phatsinhthu_usd   ,
        lw_subtotal_phatsinhchi_usd   ,
        lw_subtotal_toncuoiky_usd     ,
        gs_data-tondauky_usd          ,
        gs_data-phatsinhchi_usd       ,
        gs_data-phatsinhthu_usd       ,
        gs_data-toncuoiky_usd         ,

        lw_subtotal_tondauky_usd_c      ,
        lw_subtotal_phatsinhthu_usd_c   ,
        lw_subtotal_phatsinhchi_usd_c   ,
        lw_subtotal_toncuoiky_usd_c     ,
        gs_data-tondauky_companycode_usd          ,
        gs_data-phatsinhchi_companycode_usd       ,
        gs_data-phatsinhthu_companycode_usd       ,
        gs_data-toncuoiky_companycode_usd         ,

        "EUR
        lw_subtotal_tondauky_usd      ,
        lw_subtotal_phatsinhthu_usd   ,
        lw_subtotal_phatsinhchi_usd   ,
        lw_subtotal_toncuoiky_usd     ,
        gs_data-tondauky_usd          ,
        gs_data-phatsinhchi_usd       ,
        gs_data-phatsinhthu_usd       ,
        gs_data-toncuoiky_usd         ,

        lw_subtotal_tondauky_usd_c      ,
        lw_subtotal_phatsinhthu_usd_c   ,
        lw_subtotal_phatsinhchi_usd_c   ,
        lw_subtotal_toncuoiky_usd_c     ,
        gs_data-tondauky_companycode_usd          ,
        gs_data-phatsinhchi_companycode_usd       ,
        gs_data-phatsinhthu_companycode_usd       ,
        gs_data-toncuoiky_companycode_usd         ,


        lw_ton_vnd    ,
        lw_ton_usd    ,
        lw_ton_usd_c  ,
        lw_ton_eur    ,
        lw_ton_eur_c  .


        IF is_lastline <> 'X'.
          CONTINUE.
        ENDIF.
      ENDAT.

      "Because using CONTINUE => AT LAST BEFORE AT END OF
      AT LAST.
        "append data total
        gs_data-islevel = '2'.

        IF lv_opt = 'I' OR lv_opt = 'T'.     " Nội tệ
          "----VND---
          gs_data-tondauky_vnd     = lw_total_tondauky_vnd.
          gs_data-phatsinhchi_vnd  = lw_total_phatsinhchi_vnd.
          gs_data-phatsinhthu_vnd  = lw_total_phatsinhthu_vnd.
          gs_data-toncuoiky_vnd    = lw_total_toncuoiky_vnd.

        ELSEIF lv_opt = 'N'. " Ngoại tệ
          "------------USD----------
          gs_data-tondauky_usd     = lw_total_tondauky_usd.
          gs_data-phatsinhchi_usd  = lw_total_phatsinhchi_usd.
          gs_data-phatsinhthu_usd  = lw_total_phatsinhthu_usd.
          gs_data-toncuoiky_usd    = lw_total_toncuoiky_usd.

          "Company Code USD
          gs_data-tondauky_companycode_usd     = lw_total_tondauky_usd_c.
          gs_data-phatsinhchi_companycode_usd  = lw_total_phatsinhchi_usd_c.
          gs_data-phatsinhthu_companycode_usd  = lw_total_phatsinhthu_usd_c.
          gs_data-toncuoiky_companycode_usd    = lw_total_toncuoiky_usd_c.
          "------------USD----------


          "------------EUR----------
          gs_data-tondauky_eur     = lw_total_tondauky_eur.
          gs_data-phatsinhchi_eur  = lw_total_phatsinhchi_eur.
          gs_data-phatsinhthu_eur  = lw_total_phatsinhthu_eur.
          gs_data-toncuoiky_eur    = lw_total_toncuoiky_eur.

          "Company Code EUR
          gs_data-tondauky_companycode_eur     = lw_total_tondauky_eur_c.
          gs_data-phatsinhchi_companycode_eur  = lw_total_phatsinhchi_eur_c.
          gs_data-phatsinhthu_companycode_eur  = lw_total_phatsinhthu_eur_c.
          gs_data-toncuoiky_companycode_eur    = lw_total_toncuoiky_eur_c.
          "------------EUR----------

        ENDIF.

        APPEND gs_data TO gt_data.
      ENDAT.

    ENDLOOP.


*"============================<< Option Sum >>=================================
*    IF lv_sumtk = 'Y'. "option sum tài khoản
*
*      SELECT
*      glaccount,
*      postingdate,
*      documentdate,
*      accountingdocument,
*      assignmentreference,
*      accountname,
*      account,
*      diengiai,
*      transactioncurrency,
*      SUM( amount_local_chi )   AS amount_local_chi,
*      SUM( amount_foreign_chi ) AS amount_foreign_chi,
*      SUM( amount_local_thu )   AS amount_local_thu,
*      SUM( amount_foreign_thu ) AS amount_foreign_thu
*      FROM @gt_data AS data
*      WHERE Islevel = 0
*      GROUP BY glaccount, postingdate, documentdate, accountingdocument, assignmentreference, accountname, account, diengiai, transactioncurrency
*      ORDER BY glaccount, postingdate, documentdate, accountingdocument, assignmentreference, accountname, account, diengiai, transactioncurrency
*      INTO TABLE @DATA(lt_datasum).
*
*      DELETE ADJACENT DUPLICATES FROM gt_data COMPARING glaccount postingdate documentdate accountingdocument assignmentreference accountname account diengiai transactioncurrency.
*
*      LOOP AT gt_data_pre REFERENCE INTO DATA(gs_data_pre).
*        READ TABLE lt_datasum INTO DATA(ls_datasum)
*            WITH KEY glaccount            = gs_data_pre->glaccount
*                     postingdate          = gs_data_pre->postingdate
*                     documentdate         = gs_data_pre->documentdate
*                     accountingdocument   = gs_data_pre->accountingdocument
*                     assignmentreference  = gs_data_pre->assignmentreference
*                     accountname          = gs_data_pre->accountname
*                     account              = gs_data_pre->account
*                     diengiai             = gs_data_pre->diengiai
*                     transactioncurrency  = gs_data_pre->transactioncurrency
*                     BINARY SEARCH.
*        IF sy-subrc = 0.
*          gs_data_pre->amount_local_chi   = ls_datasum-amount_local_chi.
*          gs_data_pre->amount_foreign_chi = ls_datasum-amount_foreign_chi.
*          gs_data_pre->amount_local_thu   = ls_datasum-amount_local_thu.
*          gs_data_pre->amount_foreign_thu = ls_datasum-amount_foreign_thu.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.


  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lv_sort_string TYPE string,
          lv_grouping    TYPE string.
    DATA: systemstatus     TYPE string,
          systemstatusoper TYPE string.
    DATA(lt_fields)        = io_request->get_requested_elements( ).
    DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_top ).
    IF lv_max_rows = -1 .
      lv_max_rows = 1.
    ENDIF.
    DATA(lt_sort)          = io_request->get_sort_elements( ).
    DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN lt_sort
                                                     ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true
                                                                                            THEN ` descending`
                                                                                            ELSE ` ascending` ) ) ).
    DATA(lv_defautl) = 'AccountingDocument, CompanyCode, FiscalYear, LedgerGLLineItem'.
    lv_sort_string  = COND #( WHEN lt_sort_criteria IS INITIAL THEN lv_defautl
                                ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).


    " get filter by parameter -----------------------
    DATA(lt_paramater) = io_request->get_parameters( ).
    IF lt_paramater IS NOT INITIAL.
      LOOP AT lt_paramater REFERENCE INTO DATA(ls_parameter).
        CASE ls_parameter->parameter_name.
          WHEN 'INCLUDEREVERSEDDOCUMENT'. " YES or NO
            lv_inrev   = ls_parameter->value.
          WHEN 'FROMDATE'.
            lv_fromdate = ls_parameter->value.
          WHEN 'TODATE'.
            lv_todate   = ls_parameter->value.
          WHEN 'OPT'.
            lv_opt       = ls_parameter->value.
          WHEN 'NGAYMOSO'.
            lv_ngaymoso  = ls_parameter->value.
          WHEN 'SUMTK'. " YES or NO
            lv_sumtk     = ls_parameter->value.
        ENDCASE.
      ENDLOOP.
    ENDIF.


*    Get filter
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.
    LOOP AT lt_filter_cond REFERENCE INTO DATA(ls_filter_cond).
      IF ls_filter_cond->name = |{ 'CompanyCode' CASE = UPPER }|.
        gr_companycode        = CORRESPONDING #( ls_filter_cond->range[] ).
      ELSEIF  ls_filter_cond->name = |{ 'GLAccount' CASE = UPPER }|.
        gr_glaccount          = CORRESPONDING #( ls_filter_cond->range[] ).
      ELSEIF  ls_filter_cond->name = |{ 'TransactionCurrency' CASE = UPPER }|.
        gr_waers              = CORRESPONDING #( ls_filter_cond->range[] ).
      ENDIF.
    ENDLOOP.


    DATA(lv_entity) = io_request->get_entity_id(  ).
    CASE lv_entity.
      WHEN 'ZFI_I_SOQUY'.
        DATA: lt_data_out    TYPE TABLE OF zfi_i_soquy.

        IF lv_opt = 'I' OR lv_opt = 'T'.
          CLEAR: gr_waers.
          gr_waers = VALUE #( sign = 'I' option = 'EQ' ( low = 'VND' ) ).
        ENDIF.

        get_data(  ).

        SELECT * FROM @gt_data AS data
            ORDER BY glaccount, postingdate, accountingdocument, transactioncurrency
            INTO TABLE @lt_data_out
            OFFSET @lv_skip UP TO @lv_max_rows ROWS.

        SORT lt_data_out BY glaccount postingdate accountingdocument transactioncurrency ASCENDING islevel DESCENDING.


        " total number of record
        io_response->set_total_number_of_records( lines( lt_data_out ) )."
        " data actual response in screen //
        io_response->set_data( lt_data_out ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
