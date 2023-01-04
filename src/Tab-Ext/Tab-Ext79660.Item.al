tableextension 79660 "Tab-Ext79660" extends Item
{
    fields
    {
        field(79660; "CPC Alldevice Product Id"; Integer)
        {
            Caption = 'Alldevice Product Id';
            DataClassification = CustomerContent;
        }
        field(79661; "CPC Alldevice Spare"; Boolean)
        {
            Caption = 'Alldevice Spare';
            DataClassification = CustomerContent;
        }
        field(79662; "CPC Last Synced To Alldevice"; DateTime)
        {
            Caption = 'Last Synced To Alldevice';
            DataClassification = CustomerContent;
        }
    }
}