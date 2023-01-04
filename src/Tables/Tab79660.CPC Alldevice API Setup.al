table 79660 "CPC Alldevice API Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Alldevice API Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = true;
        }
        field(2; "CPC Alldevice API URL"; Text[100])
        {
            Caption = 'Alldevice API URL';
        }
        field(3; "CPC Alldevice API Username"; Text[100])
        {
            Caption = 'Alldevice API Username';
        }
        field(4; "CPC Alldevice API Password"; Text[100])
        {
            Caption = 'Alldevice API Password';
            ExtendedDatatype = Masked; 
        }
        field(5; "CPC Alldevice API Key"; Text[100])
        {
            Caption = 'Alldevice API Key';
            ExtendedDatatype = Masked; 
        }
        field(7; "CPC Get Spares List Prefix"; Text[50])
        {
            Caption = 'Get Spare Parts List Prefix';
        }
        field(8; "CPC Spare Part Item Template"; Code[10])
        {
            Caption = 'Spare Part Item Template';
            TableRelation = "Item Templ.";
        }
        field(10; "CPC Get Categories List Prefix"; Text[50])
        {
            Caption = 'Get Spare Part Categories List Prefix';
        }
        field(11; "CPC Main Category"; Code[20])
        {
            Caption = 'Main Spare Part Category';
            TableRelation = "Item Category";
        }
        field(12; "CPC Get Manuf. List Prefix"; Text[50])
        {
            Caption = 'Get Spare Parts Manufacturers List Prefix';
        }
        field(13; "CPC Update or Add Spare Prefix"; Text[50])
        {
            Caption = 'Update or Add Spare Part';
        }

        field(14; "CPC Get Service Task List"; Text[50])
        {
            Caption = 'Get Service Task List Prefix';
        }
        field(15; "CPC Get Used Spares List Pref."; Text[50])
        {
            Caption = 'Get Used Spares Parts List Prefix';
        }
        field(16; "CPC Update or add manuf. Pref."; Text[50])
        {
            Caption = 'Update or add Spare Part Manufacturer Prefix';
        }
        field(6; "CPC Update or add Cat. Prefix"; Text[50])
        {
            Caption = 'Update or add Spare Part Category';
        }

    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}