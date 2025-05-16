@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Profile for Supplier/Customer/Onetime of FI Doc'
define view entity ZFI_I_PROFILE_FIDOC
  as select distinct from I_OperationalAcctgDocItem
    left outer join       I_OneTimeAccountCustomer as OneTimeCustomerInfo    on  I_OperationalAcctgDocItem.AccountingDocument     = OneTimeCustomerInfo.AccountingDocument
                                                                             and I_OperationalAcctgDocItem.FiscalYear             = OneTimeCustomerInfo.FiscalYear
                                                                             and I_OperationalAcctgDocItem.CompanyCode            = OneTimeCustomerInfo.CompanyCode
                                                                             and I_OperationalAcctgDocItem.AccountingDocumentItem = OneTimeCustomerInfo.AccountingDocumentItem
    left outer join       I_Address_2              as OneTimeCustomerAddress on OneTimeCustomerAddress.AddressID = OneTimeCustomerInfo.AddressID
    left outer join       I_OneTimeAccountSupplier as OneTimeSupplierInfo    on  I_OperationalAcctgDocItem.AccountingDocument     = OneTimeSupplierInfo.AccountingDocument
                                                                             and I_OperationalAcctgDocItem.FiscalYear             = OneTimeSupplierInfo.FiscalYear
                                                                             and I_OperationalAcctgDocItem.CompanyCode            = OneTimeSupplierInfo.CompanyCode
                                                                             and I_OperationalAcctgDocItem.AccountingDocumentItem = OneTimeSupplierInfo.AccountingDocumentItem
    left outer join       I_Address_2              as OneTimeSupplierAddress on OneTimeSupplierAddress.AddressID = OneTimeSupplierInfo.AddressID
    left outer join       ZCORE_I_PROFILE_SUPPLIER as Supplier               on I_OperationalAcctgDocItem.Supplier = Supplier.Supplier
    left outer join       ZCORE_I_PROFILE_CUSTOMER as Customer               on I_OperationalAcctgDocItem.Customer = Customer.Customer
{
  key       I_OperationalAcctgDocItem.AccountingDocument,
  key       I_OperationalAcctgDocItem.FiscalYear,
  key       I_OperationalAcctgDocItem.CompanyCode,
//  key       I_OperationalAcctgDocItem.LedgerGLLineItem,
  key       I_OperationalAcctgDocItem.AccountingDocumentItem,
            ///Account
  key       case when I_OperationalAcctgDocItem.FinancialAccountType = 'D' then I_OperationalAcctgDocItem.Customer
                 when I_OperationalAcctgDocItem.FinancialAccountType = 'K' then I_OperationalAcctgDocItem.Supplier
            end                                                                                                               as Account,
  key       I_OperationalAcctgDocItem.FinancialAccountType,
            ///Account Group : check là company hay mr hay mrs
            case when I_OperationalAcctgDocItem.FinancialAccountType = 'D' then Customer.CustomerBusinessPartnerGroup
                 when I_OperationalAcctgDocItem.FinancialAccountType = 'K' then Supplier.SupplierBusinessPartnerGroup
                 end                                                                                                          as AccountBusinessPartnerGroup,
            ///Supplier
            I_OperationalAcctgDocItem.Supplier,

            ///Customer
            I_OperationalAcctgDocItem.Customer,

            /// One time customer name 2 + name 3 + name 4 (chia để trị :))
            concat_with_space( OneTimeCustomerInfo.BusinessPartnerName2,
            concat_with_space( OneTimeCustomerInfo.BusinessPartnerName3, OneTimeCustomerInfo.BusinessPartnerName4 , 1 ) , 1 ) as OneTimeCustomerNameOpt2,
            case when OneTimeCustomerInfo.BusinessPartnerName1 is not initial
                 then OneTimeCustomerInfo.BusinessPartnerName1
                 else $projection.OneTimeCustomerNameOpt2 end                                                                 as OneTimeCustomerName,

            /// One time supplier name 2 + name 3 + name 4 (chia để trị :))
            concat_with_space( OneTimeSupplierInfo.BusinessPartnerName2,
            concat_with_space( OneTimeSupplierInfo.BusinessPartnerName3, OneTimeSupplierInfo.BusinessPartnerName4 , 1 ) , 1 ) as OneTimeSupplierInfoOpt2,
            case when OneTimeSupplierInfo.BusinessPartnerName1 is not initial
                 then OneTimeSupplierInfo.BusinessPartnerName1
                 else $projection.OneTimeSupplierInfoOpt2 end                                                                 as OneTimeSupplierName,

            /// Account name
            case when OneTimeCustomerInfo.Customer is not null and I_OperationalAcctgDocItem.FinancialAccountType = 'D'
                 then $projection.OneTimeCustomerName
                 when OneTimeSupplierInfo.Supplier is not null and I_OperationalAcctgDocItem.FinancialAccountType = 'K'
                 then $projection.OneTimeSupplierName
                 when OneTimeCustomerInfo.Customer is null and I_OperationalAcctgDocItem.FinancialAccountType = 'D'
                 then Customer.CustomerFullName
                 when OneTimeSupplierInfo.Supplier is null and I_OperationalAcctgDocItem.FinancialAccountType = 'K'
                 then Supplier.SupplierFullName
            end                                                                                                               as AccountnName,

            /// Account address
            case
            //One time
                 when OneTimeCustomerInfo.Customer is not null and I_OperationalAcctgDocItem.FinancialAccountType = 'D'
                 then concat_with_space( OneTimeCustomerInfo.StreetAddressName,
                      concat_with_space( OneTimeCustomerAddress.DistrictName, OneTimeCustomerInfo.CityName, 1 ), 1)
                 when OneTimeSupplierInfo.Supplier is not null and I_OperationalAcctgDocItem.FinancialAccountType = 'K'
                 then concat_with_space( OneTimeSupplierInfo.StreetAddressName,
                      concat_with_space( OneTimeSupplierAddress.DistrictName, OneTimeSupplierInfo.CityName, 1 ), 1)
            //Master data
                 when OneTimeCustomerInfo.Customer is null and I_OperationalAcctgDocItem.FinancialAccountType = 'D'
                 then Customer.FullAddress
                 when OneTimeSupplierInfo.Supplier is null and I_OperationalAcctgDocItem.FinancialAccountType = 'K'
                 then Supplier.FullAddress
            end                                                                                                               as AccountAddress,

            //Account tax
            case
                when  I_OperationalAcctgDocItem.FinancialAccountType = 'D' then
                    case when OneTimeCustomerInfo.Customer is not null  and OneTimeCustomerInfo.TaxID1 is not initial
                         then OneTimeCustomerInfo.TaxID1
                         else Customer.TaxNumber end
                when  I_OperationalAcctgDocItem.FinancialAccountType = 'K' then
                    case when OneTimeSupplierInfo.Supplier is not null  and OneTimeSupplierInfo.TaxID1 is not initial
                         then OneTimeSupplierInfo.TaxID1
                         else Supplier.TaxNumber end
            end                                                                                                               as AccountTaxNumber,
            I_OperationalAcctgDocItem.PaymentMethod
}
where
     I_OperationalAcctgDocItem.FinancialAccountType = 'D'
  or I_OperationalAcctgDocItem.FinancialAccountType = 'K'
