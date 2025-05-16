@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ưu Tiên 3 Tên Người Nhập Nộp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_GETNAME_NNOP_UUTIEN3
  as select distinct from I_OperationalAcctgDocItem as OADI
    left outer join       I_GLAccountLineItem       as GlaItem on GlaItem.CompanyCode            = OADI.CompanyCode
                                                              and GlaItem.AccountingDocument     = OADI.AccountingDocument
                                                              and GlaItem.FiscalYear             = OADI.FiscalYear
                                                              and GlaItem.AccountingDocumentItem = OADI.AccountingDocumentItem
          
    left outer join       I_OneTimeAccountSupplier  as OneSup on  OneSup.CompanyCode            = OADI.CompanyCode
                                                              and OneSup.AccountingDocument     = OADI.AccountingDocument
                                                              and OneSup.FiscalYear             = OADI.FiscalYear
                                                              and OneSup.AccountingDocumentItem = OADI.AccountingDocumentItem
                                                              and OADI.FinancialAccountType     = 'K'
    left outer join       I_OneTimeAccountCustomer  as OneCus on  OneCus.CompanyCode            = OADI.CompanyCode
                                                              and OneCus.AccountingDocument     = OADI.AccountingDocument
                                                              and OneCus.FiscalYear             = OADI.FiscalYear
                                                              and OneCus.AccountingDocumentItem = OADI.AccountingDocumentItem
                                                              and OADI.FinancialAccountType     = 'D'
{
  key OADI.CompanyCode,
  key OADI.AccountingDocument,
  key OADI.FiscalYear,
  key GlaItem.OffsettingLedgerGLLineItem,
  
      GlaItem.FinancialAccountType,
      
      case when OneSup.CompanyCode is not initial
           then OneSup.Supplier
           when OneCus.CompanyCode is not initial
           then OneCus.Customer 
      end as account3,

      case when OneSup.CompanyCode is not initial
           then concat_with_space(
                    concat_with_space(
                        concat_with_space(OneSup.BusinessPartnerName1
                                         , OneSup.BusinessPartnerName2, 1)
                                            , OneSup.BusinessPartnerName3, 1)
                                              , OneSup.BusinessPartnerName4, 1)
          when OneCus.CompanyCode is not initial
          then concat_with_space(
                    concat_with_space(
                        concat_with_space(OneCus.BusinessPartnerName1
                                         , OneCus.BusinessPartnerName2, 1)
                                            , OneCus.BusinessPartnerName3, 1)
                                              , OneCus.BusinessPartnerName4, 1)
      end as accountname3
} where  OADI.FinancialAccountType      = 'K'
    or OADI.FinancialAccountType        = 'D'
