@EndUserText.label: 'Sổ quỹ tiền mặt'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_SOQUY'

define root custom entity ZFI_I_SOQUY
  with parameters
    @Environment.systemField:#SYSTEM_DATE
    @EndUserText.label: 'From Date'
    FromDate                : vdm_v_key_date,

    @Environment.systemField:#SYSTEM_DATE
    @EndUserText.label: 'To Date'
    ToDate                  : vdm_v_key_date,

    @Environment.systemField:#SYSTEM_DATE
    @EndUserText.label: 'Ngày Mở Sổ'
    NgayMoSo                : vdm_v_key_date,

    @Consumption.valueHelpDefinition: [{ entity: {
    name: 'ZFI_I_BOOLEAN_SVH',
    element: 'value_low'
    } }]
    @EndUserText.label: 'Include Reversed Documents'
    IncludeReversedDocument : zde_yesno,

    @Consumption.valueHelpDefinition: [{ entity: {
    name: 'ZFI_I_OPTION_IN_SVH',
    element: 'value_low'
    } }]
    @EndUserText.label: 'Loại mẫu báo cáo'
    Opt                     : zde_opt_in_soctcn,

    @Consumption.valueHelpDefinition: [{ entity: {
    name: 'ZFI_I_BOOLEAN_SVH',
    element: 'value_low'
    } }]
    @EndUserText.label: 'Tính tổng theo tài khoản'
    SumTK                   : zde_yesno

{

  key AccountingDocument          : abap.char( 10 );

      @UI.selectionField          : [{ position: 10 }]
      @Consumption.filter         : {selectionType: #SINGLE, mandatory: true}
      @Consumption.valueHelpDefinition:[{ entity: {
          name                    : 'I_CompanyCode',
          element                 : 'CompanyCode'} }]
  key CompanyCode                 : abap.char( 4 );

  key FiscalYear                  : abap.numc( 4 );
  key LedgerGLLineItem            : abap.char( 6 );


      NameCty                     : abap.char( 100 ); // (1)
      DiaChiCty                   : abap.char( 100 ); // (2)

      @UI                         : {
         selectionField           : [{ position: 30 }]}
      @Consumption.filter         : {multipleSelections: true,selectionType: #RANGE}
      @Consumption.valueHelpDefinition:[{ entity: {
          name                    : 'I_GLAccount',
          element                 : 'GLAccount'
      } }]
      GLAccount                   : abap.char( 10 ); // Tài khoản (3)
      GLAccountLongName           : abap.char( 50 ); // Name Tài khoản (3)

      PostingDate                 : abap.dats; // (6) Ngày ghi sổ
      DocumentDate                : abap.dats; // (7) Ngày chứng từ

      SoChungTuThu                : belnr_d;   // (8A) Số chứng từ Thu
      SoChungTuChi                : belnr_d;   // (8B) Số chứng từ Chi

      AccountName                 : abap.char( 100 ); // (9) Tên người nhận/nộp tiền
      Account                     : kunnr; // (10) Mã người nhận/nộp tiền

      DienGiai                    : abap.char( 50 ); // (11) Diễn giải

      AssignmentReference         : abap.char( 18 ); // (25) Assigment


      @EndUserText.label          : 'Currency'
      @Consumption.filter         : {selectionType: #RANGE, mandatory: true}
      @Consumption.valueHelpDefinition:[{ entity: {
        name                      : 'ZFI_I_Currency_SVH',
        element                   : 'Currency'
        } }]
      TransactionCurrency         : zde_curr;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      Amount_Foreign_Thu          : abap.curr( 25 , 2 ); //ngoại tệ thu
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      Amount_Foreign_Chi          : abap.curr( 25 , 2 ); //ngoại tệ chi
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      Amount_Foreign_Ton          : abap.curr( 25 , 2 ); //ngoại tệ tồn


      CompanyCodeCurrency         : zde_curr;
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      Amount_Local_Thu            : abap.curr( 25 , 2 ); //local thu
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      Amount_Local_Chi            : abap.curr( 25 , 2 ); //local chi
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      Amount_Local_Ton            : abap.curr( 25 , 2 ); //local tồn


      //VND
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      TonDauKy_VND                : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      PhatSinhThu_VND             : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      PhatSinhChi_VND             : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      TonCuoiKy_VND               : abap.curr( 25 , 2 );

      //USD
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      TonDauKy_USD                : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      PhatSinhThu_USD             : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      PhatSinhChi_USD             : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      TonCuoiKy_USD               : abap.curr( 25 , 2 );

      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      TonDauKy_CompanyCode_USD    : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      PhatSinhThu_CompanyCode_USD : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      PhatSinhChi_CompanyCode_USD : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      TonCuoiKy_CompanyCode_USD   : abap.curr( 25 , 2 );

      //EUR
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      TonDauKy_EUR                : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      PhatSinhThu_EUR             : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      PhatSinhChi_EUR             : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      TonCuoiKy_EUR               : abap.curr( 25 , 2 );

      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      TonDauKy_CompanyCode_EUR    : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      PhatSinhThu_CompanyCode_EUR : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      PhatSinhChi_CompanyCode_EUR : abap.curr( 25 , 2 );
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      TonCuoiKy_CompanyCode_EUR   : abap.curr( 25 , 2 );



      Islevel                     : abap.char(1); // is 0: items, 1: subtotal, 2: total

      financialaccounttype        : abap.char(1);
      IsNegativePosting           : abap.char(1);
      DebitCreditCode             : abap.char(1);
      accountingdocumentitem      : buzei;
      sourceledger                : abap.char(2);
      ledger                      : abap.char(2);

}
