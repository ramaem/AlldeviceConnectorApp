page 79663 "CPC Alldevice Tasks List"
{
    Caption = 'Alldevice Service Tasks List';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "CPC Alldevice Service Tasks";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("CPC Task Id"; Rec."CPC Task Id")
                {
                    ApplicationArea = All;
                }
                field("CPC Device Name"; Rec."CPC Device Name")
                {
                    ApplicationArea = All;
                }
                field("CPC Service Name"; Rec."CPC Service Name")
                {
                    ApplicationArea = All;
                }
                field("CPC Service Description"; Rec."CPC Service Description")
                {
                    ApplicationArea = All;
                }
                field("CPC Created On"; Rec."CPC Created On")
                {
                    ApplicationArea = All;
                }
                field("CPC Task Status"; Rec."CPC Task Status")
                {
                    ApplicationArea = All;
                }
                field("CPC Device Status"; Rec."CPC Device Status")
                {
                    ApplicationArea = All;
                }
                field("CPC Is Completed"; Rec."CPC Is Completed")
                {
                    ApplicationArea = All;
                }
                field("CPC Completed Date"; Rec."CPC Completed Date")
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
        area(Creation)
        {
            action(CreateItemJrnlLines)
            {
                ApplicationArea = All;
                Image = Create;
                Caption = 'Create Item Jrnl. Lines';

                trigger OnAction();
                var
                    ServiceTaskLines: Record "CPC Alld. Service Task Lines";
                begin
                    Clear(AlldeviceItemJourLines);
                    AlldeviceTasks.GetUsedSparesList(ServiceTaskLines, Rec."CPC Task Id");
                    Commit();
                    AlldeviceItemJourLines.SetTaskId(Rec."CPC Task Id");
                    AlldeviceItemJourLines.RunModal();
                end;
            }
        }
        area(Promoted)
        {
            actionref(CreateItemJrnlLines1; CreateItemJrnlLines)
            {
            }
        }
    }

    trigger OnInit()
    begin
        AlldeviceTasks.GetTasksRecord(Rec);
    end;

    var
        AlldeviceTasks: Codeunit "CPC Alldevice Tasks";
        AlldeviceItemJourLines: Report "CPC Alldevice Item Jour. Lines";
}