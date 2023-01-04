table 79663 "CPC Alld. Service Task Lines"
{
    DataClassification = CustomerContent;
    Caption = 'Alldevice Service Task Lines';
    
    fields
    {
        field(1;"CPC Id"; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "CPC Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(3; "CPC Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(4; "CPC Name"; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(5; "CPC Alldevice Task Id"; Integer)
        {
            Caption = 'Task Id';
            DataClassification = CustomerContent;
        }
        
    }
    
    keys
    {
        key(PK; "CPC Id")
        {
            Clustered = true;
        }
    }
    
}