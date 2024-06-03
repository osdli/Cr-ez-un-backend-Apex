@isTest
public class TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        return acc;
    }

    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            ContractTerm = 12,
            StartDate = Date.today() 
        );
        insert contract;
        return contract;
    }

    public static Id createTestProductAndPriceBookEntry() {
        Product2 prod = new Product2(Name = 'GenWatt Diesel 10kW', ProductCode = 'GC1020');
        insert prod;

        Id standardPBId = Test.getStandardPricebookId();

        PriceBookEntry standardPBE = new PriceBookEntry(
            Product2Id = prod.Id,
            PriceBook2Id = standardPBId,
            UnitPrice = 5000.00,
            IsActive = true
        );
        insert standardPBE;
        
        return standardPBE.Id;
    }
}
