page 79661 "CPC Alldevice API Logs"
{
    Caption = 'Alldevice API Logs';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "CPC Alldevice API Logs";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Time"; Rec."CPC Entry Time")
                {
                    ApplicationArea = All;
                }
                field("API Request Sucess"; Rec."CPC API Request Sucess")
                {
                    ApplicationArea = All;
                }
                field("CPC Sent To Address Prefix"; Rec."CPC Address Prefix")
                {
                    ApplicationArea = All;
                }
                field("CPC Error From BC"; Rec."CPC Error From BC")
                {
                    ApplicationArea = All;
                }
                field("CPC Additional Information"; Rec."CPC Additional Information")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewResponseJson)
            {
                ApplicationArea = All;
                Caption = 'View Response JSON';
                Image = Import;

                trigger OnAction()
                begin
                    Rec.OpenResponseJson();
                end;
            }
            action(ViewSentJson)
            {
                ApplicationArea = All;
                Caption = 'View Sent JSON';
                Image = Export;

                trigger OnAction()
                begin
                    Rec.OpenResponseJson();
                end;
            }
        }
    }
}