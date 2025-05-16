@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ưu Tiên 2 Tên Người Nhập Nộp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_GETNAME_NNOP_UUTIEN2
  as select distinct from I_OperationalAcctgDocItem as OADI
    left outer join       I_GLAccountLineItem       as GlaItem on GlaItem.CompanyCode        = OADI.CompanyCode
                                                              and GlaItem.AccountingDocument = OADI.AccountingDocument
                                                              and GlaItem.FiscalYear         = OADI.FiscalYear
                                                              and GlaItem.AccountingDocumentItem = OADI.AccountingDocumentItem
    left outer join       I_Supplier                as Sup on  Sup.Supplier              = OADI.Supplier
                                                           and OADI.FinancialAccountType = 'K'
                                                           and Sup.IsOneTimeAccount      = ''
    left outer join       I_Customer                as Cus on  Cus.Customer              = OADI.Customer
                                                           and OADI.FinancialAccountType = 'D'
                                                           and Cus.IsOneTimeAccount      = ''
{
  key OADI.CompanyCode,
  key OADI.AccountingDocument,
  key OADI.FiscalYear,
//  key OADI.AccountingDocumentItem,
  key GlaItem.OffsettingLedgerGLLineItem,
  
  case when Sup.Supplier is not initial
       then Sup.Supplier
       when Cus.Customer is not initial 
       then Cus.Customer
  end  as account2,
  
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
  end as accountname2

}
where
  (
       OADI.AlternativePayeePayer       = ''
  )
  and(
       OADI.FinancialAccountType        = 'K'
    or OADI.FinancialAccountType        = 'D'
  )
  and  OADI.AddressAndBankIsSetManually = ''
  and ( Sup.Supplier is not initial
      or Cus.Customer is not initial )
