@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sổ quỹ tiền mặt header'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZFI_SOQUY_HEADER
  with parameters
    @Environment.systemField:#SYSTEM_DATE
    FromDate          : vdm_v_key_date,
    @Environment.systemField:#SYSTEM_DATE
    ToDate            : vdm_v_key_date,
    @Environment.systemField:#SYSTEM_DATE
    NgayMoSo          : vdm_v_key_date,
    IsIncludeReversed : zde_boolean
  as select distinct from I_OperationalAcctgDocItem                                  as OADI
    inner join            I_JournalEntry                                             as je                on  je.CompanyCode        =    OADI.CompanyCode
                                                                                                          and je.FiscalYear         =    OADI.FiscalYear
                                                                                                          and je.AccountingDocument =    OADI.AccountingDocument
                                                                                                          and (
                                                                                                             OADI.GLAccount          like '111%'
                                                                                                             or OADI.GLAccount       like '112%'
                                                                                                           )
//                                                                                                          and OADI.Ledger            like '0L'
  //                                                                                                          and (
  //                                                                                                             $parameters.IsIncludeReversed   is not initial
  //                                                                                                             or(
  //                                                                                                               $parameters.IsIncludeReversed is initial
  //                                                                                                               and(
  //                                                                                                                 je.IsReversal               is initial
  //                                                                                                                 or je.IsReversal            is null
  //                                                                                                               )
  //                                                                                                               and(
  //                                                                                                                 je.IsReversed               is initial
  //                                                                                                                 or je.IsReversed            is null
  //                                                                                                               )
  //                                                                                                             )
  //                                                                                                           )
    inner join            I_CompanyCode                                              as company           on OADI.CompanyCode = company.CompanyCode


    left outer join       I_AddrOrgNamePostalAddress                                 as company_address   on company.AddressID = company_address.AddressID
    left outer join       ZFI_I_SOQUY_SOTIENDAUKI_VND(FromDate:$parameters.FromDate) as SumTonDauKyVND    on  OADI.CompanyCode = SumTonDauKyVND.CompanyCode
                                                                                                          and OADI.GLAccount   = SumTonDauKyVND.GLAccount
    left outer join       ZFI_I_SOQUY_SOTIENDAUKI_NT(FromDate:$parameters.FromDate)  as SumTonDauKyNT     on  OADI.CompanyCode = SumTonDauKyNT.CompanyCode
                                                                                                          and OADI.GLAccount   = SumTonDauKyNT.GLAccount
    left outer join       ZI_CHUKY                                                   as ChuKiNguoiDaiDien on ChuKiNguoiDaiDien.Id = 'NGUOIDAIIDIEN'
    left outer join       ZI_CHUKY                                                   as ktt               on ktt.Id = 'KETOANTRUONG'
    left outer join       ZI_CHUKY                                                   as thuQuy            on thuQuy.Id = 'THUQUY'
    left outer join       I_Address_2                                                as adr2              on company.AddressID = adr2.AddressID
  association to I_GlAccountTextInCompanycode as _GLAccountTextInCompanyCode on  _GLAccountTextInCompanyCode.CompanyCode = OADI.CompanyCode
                                                                             and _GLAccountTextInCompanyCode.GLAccount   = OADI.GLAccount
                                                                             and _GLAccountTextInCompanyCode.Language    = 'E'
  composition [0..*] of ZFI_I_SOQUY_ITEM      as _Item
{
      @Consumption.filter: { mandatory: true , selectionType: #SINGLE,
      multipleSelections: false , defaultValue: '1000' }
  key OADI.CompanyCode,
  key OADI.AccountingDocument,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_GLAccountInChartOfAccounts', element: 'GLAccount' }}]
      @ObjectModel.text.element: ['GLAccount']
      @Search.defaultSearchElement: true
      OADI.GLAccount,
      cast(OADI.TransactionCurrency as zde_currency)                                                                                                                                                         as Currency,
      _GLAccountTextInCompanyCode.GLAccountLongName,
      @Search.defaultSearchElement: true
      concat_with_space(company_address.AddresseeName1,company_address.AddresseeName2,1)                                                                                                                    as CompanyCodeName,
      //      concat_with_space(concat(company_address.StreetName,','),company_address.CityName,1) as DiaChiCty,
      concat_with_space(concat_with_space(concat_with_space(company_address.StreetName, company_address.StreetPrefixName1, 1), company_address.StreetPrefixName2, 1), company_address.StreetSuffixName1, 1) as DiaChiCty,
      adr2.HouseNumber                                                                                                                                                                                      as HouseNumberDiaChi,
      adr2.CityName                                                                                                                                                                                         as DiaChiCityName, //BC2
      adr2.Street,
      $parameters.FromDate                                                                                                                                                                                  as FromDat1,
      $parameters.ToDate                                                                                                                                                                                    as ToDat2,
      @Search.defaultSearchElement: true
      OADI.PostingDate,
      @Semantics.amount.currencyCode: 'Currency'
      SumTonDauKyVND.SumAmountInCompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'Currency'
      SumTonDauKyNT.SumAmountInTransactionCurrency,
      //Chữ Ký
      @Consumption.filter.hidden: true
      ChuKiNguoiDaiDien.Hoten                                                                                                                                                                               as NguoiDaiDien,
      @Consumption.filter.hidden: true
      ktt.Hoten                                                                                                                                                                                             as KeToan,
      @Consumption.filter.hidden: true
      thuQuy.Hoten                                                                                                                                                                                          as ThuQuy,
      _Item
}
where
  (
    (
             OADI.GLAccount                 like '111%'
      or     OADI.GLAccount                 like '112%'
    )
    and(
      (
             $parameters.FromDate          <=   OADI.PostingDate
      )
      and(
             $parameters.ToDate            >=   OADI.PostingDate
      )
    )
    and(
             $parameters.IsIncludeReversed is not initial
      or(
             $parameters.IsIncludeReversed is initial
        and(
             je.IsReversal                 is initial
          or je.IsReversal                 is null
        )
        and(
             je.IsReversed                 is initial
          or je.IsReversed                 is null
        )
      )
    )
  )
