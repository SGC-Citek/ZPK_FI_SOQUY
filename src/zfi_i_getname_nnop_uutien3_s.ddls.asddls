@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ưu Tiên 3 với tài khoản đối ứng loại S'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_GETNAME_NNOP_UUTIEN3_S
  as select from    I_GLAccountLineItem as item
    left outer join I_Supplier          as Sup on  Sup.Supplier              = item.Supplier
                                               and item.FinancialAccountType = 'K'
    left outer join I_Customer          as Cus on  Cus.Customer              = item.Customer
                                               and item.FinancialAccountType = 'D'

{
  key item.SourceLedger,
  key item.CompanyCode,
  key item.FiscalYear,
  key item.AccountingDocument,
  key item.Ledger,
  key item.LedgerGLLineItem,
      //  key OADI.AccountingDocumentItem,

      case when item.FinancialAccountType  =  'K'
           then item.Supplier
           when item.FinancialAccountType  =  'D'
           then item.Customer
      end as ma,

      case when Sup.Supplier is not initial
               then case when  Sup.BusinessPartnerName2 <> ''
                            or Sup.BusinessPartnerName3 <> ''
                            or Sup.BusinessPartnerName4 <> ''
                         then concat_with_space( Sup.BusinessPartnerName2,
                                 concat_with_space( Sup.BusinessPartnerName3, Sup.BusinessPartnerName4, 1 ) , 1)
                         else Sup.BusinessPartnerName1
                     end
                when Cus.Customer is not initial
                         then case when  Cus.BusinessPartnerName2 <> ''
                            or Cus.BusinessPartnerName3 <> ''
                            or Cus.BusinessPartnerName4 <> ''
                         then concat_with_space( Cus.BusinessPartnerName2,
                                 concat_with_space( Cus.BusinessPartnerName3, Cus.BusinessPartnerName4, 1 ) , 1)
                         else Cus.BusinessPartnerName1
                     end
      end as accountname3S

}
where
  (
       item.FinancialAccountType = 'K'
    or item.FinancialAccountType = 'D'
  )
  and  item.Ledger               = '0L'
