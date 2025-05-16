@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sổ quỹ tiền mặt item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SOQUY_ITEM
  as select distinct from I_JournalEntry              as je
//    inner join            I_JournalEntryItem          as item         on  je.CompanyCode        = item.CompanyCode
//                                                                      and je.FiscalYear         = item.FiscalYear
//                                                                      and je.AccountingDocument = item.AccountingDocument
    left outer join       ZFI_I_SOQUY_CTU_THUCHI as chiThu            on  chiThu.CompanyCode            =  je.CompanyCode
                                                                      and chiThu.FiscalYear             =  je.FiscalYear
                                                                      and chiThu.AccountingDocument     =  je.AccountingDocument
//                                                                      and chiThu.AccountingDocumentItem =  item.AccountingDocumentItem
//                                                                      and (
//                                                                         chiThu.Account                 =  item.Supplier
//                                                                         or chiThu.Account              =  item.Customer
//                                                                       )
//                                                                      and (
//                                                                         chiThu.SoChungTuChi            <> ''
//                                                                         or chiThu.SoChungTuThu         <> ''
//                                                                       )
    left outer join       ZCORE_I_PROFILE_CUSTOMER    as customer     on customer.Customer = chiThu.Customer
    left outer join       ZCORE_I_PROFILE_SUPPLIER    as supplier     on supplier.Supplier = chiThu.Supplier
  // -> ALTERNATIVE CHO ĐỐI TƯỢNG CỦA LINE CHI PHÍ
    left outer join       ZFI_I_PROFILE_FIDOC       as profileFIDoc on  profileFIDoc.CompanyCode        =    je.CompanyCode
                                                                      and profileFIDoc.AccountingDocument =    je.AccountingDocument
                                                                      and profileFIDoc.AccountingDocumentItem   =    chiThu.AccountingDocumentItem
                                                                      and profileFIDoc.FiscalYear         =    je.FiscalYear
                                                                      and chiThu.GLAccount                  like '0064%'
                                                                      
//    left outer join       ZFI_I_GETNAME_UUTIEN1       as uuTien1      on  uuTien1.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTien1.CompanyCode            = je.CompanyCode
//                                                                      and uuTien1.FiscalYear             = je.FiscalYear
//                                                                      and uuTien1.AccountingDocumentItem = item.AccountingDocumentItem
//    left outer join       ZFI_GETNAME_UUTIEN2         as uuTien2      on  uuTien2.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTien2.CompanyCode            = je.CompanyCode
//                                                                      and uuTien2.FiscalYear             = je.FiscalYear
//                                                                      and uuTien2.AccountingDocumentItem = item.AccountingDocumentItem
//    left outer join       ZFI_I_GETNAME_UUTIEN3       as uuTien3      on  uuTien3.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTien3.CompanyCode            = je.CompanyCode
//                                                                      and uuTien3.FiscalYear             = je.FiscalYear
//                                                                      and uuTien3.AccountingDocumentItem = item.AccountingDocumentItem
//    left outer join       ZFI_I_GETNAME_UUTIEN4       as uuTien4      on  uuTien4.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTien4.CompanyCode            = je.CompanyCode
//                                                                      and uuTien4.FiscalYear             = je.FiscalYear
//                                                                      and uuTien4.AccountingDocumentItem = item.AccountingDocumentItem
//    left outer join       ZFI_I_GETNAME_UUTIEN5       as uuTien5      on  uuTien5.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTien5.CompanyCode            = je.CompanyCode
//                                                                      and uuTien5.FiscalYear             = je.FiscalYear
//                                                                      and uuTien5.AccountingDocumentItem = item.AccountingDocumentItem
                                                                      
//    left outer join       I_SupplierInvoiceAPI01      as sia          on sia.SupplierInvoiceWthnFiscalYear = je.OriginalReferenceDocument
    
//    left outer join       ZFI_GETNAMECUS_1            as uuTienCus1   on  uuTienCus1.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTienCus1.CompanyCode            = je.CompanyCode
//                                                                      and uuTienCus1.FiscalYear             = je.FiscalYear
//                                                                      and uuTienCus1.AccountingDocumentItem = item.AccountingDocumentItem
//    left outer join       ZFI_GETNAMECUS_2            as uuTienCus2   on  uuTienCus2.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTienCus2.CompanyCode            = je.CompanyCode
//                                                                      and uuTienCus2.FiscalYear             = je.FiscalYear
//                                                                      and uuTienCus2.AccountingDocumentItem = item.AccountingDocumentItem
//    left outer join       ZFI_GETNAMECUS_4            as uuTienCus4   on  uuTienCus4.AccountingDocument     = je.AccountingDocument
//                                                                      and uuTienCus4.CompanyCode            = je.CompanyCode
//                                                                      and uuTienCus4.FiscalYear             = je.FiscalYear
//                                                                      and uuTienCus4.AccountingDocumentItem = item.AccountingDocumentItem
                                                                      
    left outer join       ZFI_I_SOQUY_GETGLACCOUNTFEE as accountFee   on  accountFee.AccountingDocument =  je.AccountingDocument
                                                                      and accountFee.FiscalYear         =  je.FiscalYear
                                                                      and accountFee.CompanyCode        =  je.CompanyCode
                                                                      and accountFee.MarkFee            <> ''
                                                                      
    left outer join       ZFI_I_GETNAME_NNOP_UUTIEN1  as uuTien1      on  uuTien1.AccountingDocument     = je.AccountingDocument
                                                                      and uuTien1.CompanyCode            = je.CompanyCode
                                                                      and uuTien1.FiscalYear             = je.FiscalYear
//                                                                      and uuTien1.AccountingDocumentItem = item.AccountingDocumentItem    
                                                                      
    left outer join       ZFI_I_GETNAME_NNOP_UUTIEN2  as uuTien2      on  uuTien2.AccountingDocument     = je.AccountingDocument
                                                                      and uuTien2.CompanyCode            = je.CompanyCode
                                                                      and uuTien2.FiscalYear             = je.FiscalYear
//                                                                      and uuTien2.AccountingDocumentItem = item.AccountingDocumentItem  
                                                                      
    left outer join       ZFI_I_GETNAME_NNOP_UUTIEN3  as uuTien3      on  uuTien3.AccountingDocument     = je.AccountingDocument
                                                                      and uuTien3.CompanyCode            = je.CompanyCode
                                                                      and uuTien3.FiscalYear             = je.FiscalYear
//                                                                      and uuTien3.AccountingDocumentItem = item.AccountingDocumentItem   
                                                                      
    left outer join       ZFI_I_MA_NNOP  as maNNOP                    on  maNNOP.AccountingDocument     = je.AccountingDocument
                                                                      and maNNOP.CompanyCode            = je.CompanyCode
                                                                      and maNNOP.FiscalYear             = je.FiscalYear
//                                                                      and maNNOP.AccountingDocumentItem = item.AccountingDocumentItem                                                              
    
  association to parent ZFI_SOQUY_HEADER as _Header on  $projection.CompanyCode        = _Header.CompanyCode
  //and $projection.TransactionCurrency = _Header.Currency
                                                    and $projection.AccountingDocument = _Header.AccountingDocument
  //and $projection.GLAccount = _Header.GLAccount
{
  key je.CompanyCode,
  key je.AccountingDocument,
  key chiThu.AccountingDocumentItem,
  key chiThu.GLAccount,
  key chiThu.TransactionCurrency,
      je.FiscalYear,
      case
        when chiThu.FinancialAccountType = 'K' then chiThu.Supplier
        when chiThu.FinancialAccountType = 'D' then chiThu.Customer
      //when item.FinancialAccountType = 'S' and item.GLAccount like '0064%' then profileFIDoc.Account
      end                   as Account,
      chiThu.FinancialAccountType,
      je.PostingDate,
      je.DocumentDate,
      chiThu.SoChungTuThu   as SoChungTuThu,
      chiThu.SoChungTuChi   as SoChungTuChi,
      
//      case   
//             when uuTien1.name1 is not initial
//                then uuTien1.name1
//             when uuTien2.name2 is not initial
//                 then uuTien2.name2
//             when uuTien3.name3 is not initial and chiThu.AddressAndBankIsSetManually is null
//                 then uuTien3.name3
//             when uuTien4.name4 is not initial
//                 then uuTien4.name4
//             when uuTien5.name5 is not initial
//                 then uuTien5.name5
//      end                   as TenNguoiMua,

//      case
////        when sia.YY1_NCC_MIH <>''
////            then sia.YY1_NCC_MIH
//        when uuTienCus1.Name1 is not initial
//            then uuTienCus1.Name1
//        when uuTienCus2.name2 is not initial
//            then uuTienCus2.name2
//        when uuTienCus4.name4 is not initial
//            then uuTienCus4.name4
//      end                   as TenNguoiBan,

//      case when uuTien1.name1 <> ''
//           then uuTien1.name1
//           when uuTien2.name2 <> ''
//           then uuTien2.name2
//           when uuTien3.name3 <> ''
//           then uuTien3.name3
//           else ''  // ưu tiên 4
//      end as TenNguoiNNTien,

//      case
//        when chiThu.Customer is null or chiThu.Customer is initial
//            then supplier.SupplierFullName
//        else customer.CustomerFullName
//      end                   as TenNguoiNNTien1,
      
//      case
//        when $projection.TenNguoiBan is null
//            then $projection.TenNguoiMua
//        else $projection.TenNguoiBan
//      end                   as TenNguoiNNTien2,

//      case
//        when $projection.TenNguoiNNTien2 is null
//            then $projection.TenNguoiNNTien1
//        else $projection.TenNguoiNNTien2
//      end      as TenNguoiNNTien,
      
      chiThu.Account        as MaNguoiNNTien1,
//      case  when uuTienCus1.AlternativePayeePayer <>''
//                then uuTienCus1.AlternativePayeePayer
//            else uuTien2.AlternativePayeePayer
//      end                   as MaNguoiNNTien2,
      maNNOP.ma as MaNguoiNNTien2,

      case
        when $projection.MaNguoiNNTien2 <> ''
            then $projection.MaNguoiNNTien2
        else $projection.MaNguoiNNTien1
      end                   as MaNguoiNNTien,
      case
          when chiThu.DocumentItemText <> ''
                      then chiThu.DocumentItemText
                      else je.AccountingDocumentHeaderText
      end                   as DienGiai,
      je.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      case
          when chiThu.SoChungTuThu <>''  and chiThu.CompanyCodeCurrency = 'VND' //and chiThu.Account = item.Customer
              then chiThu.AmountInCompanyCodeCurrency
      end                   as SoTienThuVND,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case
          when chiThu.SoChungTuThu <>'' and chiThu.TransactionCurrency <> 'VND' //and chiThu.Account = item.Customer
              then chiThu.AmountInTransactionCurrency
      end                   as SoTienThuNT,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      case
         when  chiThu.SoChungTuChi <>'' and chiThu.CompanyCodeCurrency = 'VND' //and chiThu.Account = item.Supplier
             then chiThu.AmountInCompanyCodeCurrency
      end                   as SoTienChiVND,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case
         when  chiThu.SoChungTuChi <>'' and  chiThu.TransactionCurrency <> 'VND' //and chiThu.Account = item.Supplier
             then chiThu.AmountInTransactionCurrency
      end                   as SoTienChiNT,
      chiThu.IsNegativePosting,
      chiThu.DebitCreditCode,
      accountFee.MarkFee,
      _Header
}
where
  (
       ///chiThu.Account      <> ''
       chiThu.SoChungTuThu <> ''
    or chiThu.SoChungTuChi <> ''
  )
