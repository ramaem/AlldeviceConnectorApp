page 79660 "CPC Alldevice API Setup"
{
    ApplicationArea = All;
    Caption = 'Alldevice API Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "CPC Alldevice API Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("CPC Alldevice API URL"; Rec."CPC Alldevice API URL")
                {
                    ApplicationArea = All;
                }
                field("CPC Alldevice API Username"; Rec."CPC Alldevice API Username")
                {
                    ApplicationArea = All;
                }
                field("CPC Alldevice API Password"; Rec."CPC Alldevice API Password")
                {
                    ApplicationArea = All;
                }
                field("CPC Alldevice API Key"; Rec."CPC Alldevice API Key")
                {
                    ApplicationArea = All;
                }

            }
            group(Entities)
            {
                Caption = 'Entities';
                group("Spare Parts")
                {
                    Caption = 'Spare Parts';
                    field("CPC Spare Part Item Template"; Rec."CPC Spare Part Item Template")
                    {
                        ApplicationArea = All;
                    }
                    field("CPC Get Spares List Prefix"; Rec."CPC Get Spares List Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("CPC Update or Add Spare Prefix"; Rec."CPC Update or Add Spare Prefix")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Spare Parts Categories")
                {
                    Caption = 'Spare Parts Categories';
                    field("CPC Main Category"; Rec."CPC Main Category")
                    {
                        ApplicationArea = All;
                    }
                    field("CPC Get Categories List Prefix"; Rec."CPC Get Categories List Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("CPC Update or add Cat. Prefix"; Rec."CPC Update or add Cat. Prefix")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Spare Parts Manufacturers")
                {
                    Caption = 'Spare Parts Manufacturers';
                    field("CPC Get Manuf. List Prefix"; Rec."CPC Get Manuf. List Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("CPC Update or add manuf. Pref."; Rec."CPC Update or add manuf. Pref.")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Service Tasks")
                {
                    Caption = 'Service Tasks';
                    field("CPC Get Service Task List"; Rec."CPC Get Service Task List")
                    {
                        ApplicationArea = All;
                    }
                    field("CPC Get Used Spares List Pref."; Rec."CPC Get Used Spares List Pref.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(GetSpares)
            {
                ApplicationArea = All;
                Caption = 'Sync Spare Parts';
                Image = NewItem;

                trigger OnAction()
                begin
                    AlldeviceSpares.Run();
                end;
            }

            action(GetCategories)
            {
                ApplicationArea = All;
                Caption = 'Sync Spare Part Categories';
                Image = Category;

                trigger OnAction()
                begin
                    AlldeviceCategories.Run();
                end;
            }

            action(GetManufacturers)
            {
                ApplicationArea = All;
                Caption = 'Sync Spare Part Manufacturers';
                Image = MapAccounts;

                trigger OnAction()
                begin
                    AlldeviceManufacturer.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        AlldeviceCategories: Codeunit "CPC Alldevice Categories";
        AlldeviceManufacturer: Codeunit "CPC Alldevice Manufacturer";
        AlldeviceSpares: Codeunit "CPC Alldevice Spares";
}