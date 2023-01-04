table 79662 "CPC Alldevice Service Tasks"
{
    DataClassification = CustomerContent;
    Caption = 'Alldevice Posted Tasks';
    
    fields
    {
        field(1;"CPC Task Id"; Integer)
        {
            Caption = 'Task Id';
            DataClassification = CustomerContent;
        }
        field(2; "CPC Device Name"; Text[250])
        {
            Caption = 'Task Name';
            DataClassification = CustomerContent;
        }
        field(3; "CPC Service Name"; Text[250])
        {
            Caption = 'Service Name';
            DataClassification = CustomerContent;
        }
        field(4; "CPC Service Description"; Text[250])
        {
            Caption = 'Service Description';
            DataClassification = CustomerContent;
        }
        field(5; "CPC Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = CustomerContent;
        }
        field(6; "CPC Task Status"; Text[250])
        {
            Caption = 'Task Status';
            DataClassification = CustomerContent;
        }
        field(7; "CPC Device Status"; Text[250])
        {
            Caption = 'CPC Device Status';
            DataClassification = CustomerContent;
        }
        field(8; "CPC Is Completed"; Boolean)
        {
            Caption = 'Is Completed';
            DataClassification = CustomerContent;
        }
        field(9; "CPC Completed Date"; Date)
        {
            Caption = 'Completed Date';
            DataClassification = CustomerContent;
        }
    }
    
    keys
    {
        key(PK; "CPC Task Id")
        {
            Clustered = true;
        }
    }   
}