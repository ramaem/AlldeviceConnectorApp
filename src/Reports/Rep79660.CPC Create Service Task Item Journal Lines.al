report 79660 "CPC Alldevice Item Jour. Lines"
{
    Caption = 'Create Service Task Item Journal Lines';
    ProcessingOnly = true;
    UsageCategory = Tasks;


    dataset
    {
        dataitem(TaskLine; "CPC Alld. Service Task Lines")
        {
            trigger OnAfterGetRecord()
            var
                StdItemJnlLine: Record "Standard Item Journal Line";
            begin
                ItemJnlLine.Init();
                if GetStandardJournalLine() then begin
                    Initialize(StdItemJnl, ItemJnlBatch.Name);

                    StdItemJnlLine.SetRange("Journal Template Name", StdItemJnl."Journal Template Name");
                    StdItemJnlLine.SetRange("Standard Journal Code", StdItemJnl.Code);
                    if StdItemJnlLine.FindSet() then
                        repeat
                            CopyItemJnlFromStdJnl(StdItemJnlLine, ItemJnlLine);
                            ItemJnlLine.Validate("Entry Type", EntryTypes);
                            ItemJnlLine.Validate("Item No.", "CPC Code");
                            ItemJnlLine.Validate(Quantity, "CPC Quantity");

                            if PostingDate <> 0D then
                                ItemJnlLine.Validate("Posting Date", PostingDate);

                            if DocumentDate <> 0D then begin
                                ItemJnlLine.Validate("Posting Date", DocumentDate);
                                ItemJnlLine."Posting Date" := PostingDate;
                            end;

                            if not ItemJnlLine.Insert(true) then
                                ItemJnlLine.Modify(true);
                        until StdItemJnlLine.Next() = 0;
                end else begin
                    ItemJnlLine.Validate("Journal Template Name", ItemJnlLine.GetFilter("Journal Template Name"));
                    ItemJnlLine.Validate("Journal Batch Name", BatchName);
                    ItemJnlLine."Line No." := LineNo;
                    LineNo := LineNo + 10000;

                    ItemJnlLine.Validate("Entry Type", EntryTypes);
                    ItemJnlLine.Validate("Item No.", "CPC Code");
                    ItemJnlLine.Validate(Quantity, "CPC Quantity");

                    if PostingDate <> 0D then
                        ItemJnlLine.Validate("Posting Date", PostingDate);

                    if DocumentDate <> 0D then begin
                        ItemJnlLine.Validate("Posting Date", DocumentDate);
                        ItemJnlLine."Posting Date" := PostingDate;
                    end;

                    if (ItemJnlLine."Document No." = '') and (DocumentNo <> '') then
                        ItemJnlLine.Validate("Document No.", DocumentNo);

                    if not ItemJnlLine.Insert(true) then
                        ItemJnlLine.Modify(true);
                end;
            end;

            trigger OnPreDataItem()
            begin
                CheckJournalTemplate();
                CheckBatchName();
                CheckPostingDate();

                TaskLine.SetRange("CPC Alldevice Task Id", TaskId);

                ItemJnlLine.SetRange("Journal Template Name", JournalTemplate);
                ItemJnlLine.SetRange("Journal Batch Name", BatchName);
                if ItemJnlLine.FindLast() then
                    LineNo := ItemJnlLine."Line No." + 10000
                else
                    LineNo := 10000;

                ItemJnlBatch.Get(JournalTemplate, BatchName);
                if TemplateCode <> '' then
                    StdItemJnl.Get(JournalTemplate, TemplateCode);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(EntryTypes; EntryTypes)
                    {
                        ApplicationArea = All;
                        Caption = 'Entry Type';
                        OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.';
                        ToolTip = 'Specifies the entry type.';
                    }
                    field(DocumentNo; DocumentNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the default document number of the journal line.';
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date for the posting of this batch job. By default, the working date is entered, but you can change it.';

                        trigger OnValidate()
                        begin
                            CheckPostingDate();
                        end;
                    }
                    field(DocumentDate; DocumentDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Document Date';
                        ToolTip = 'Specifies the document date that will be inserted on the created records.';
                    }
                    field(JournalTemplate; JournalTemplate)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template';
                        TableRelation = "Item Journal Template".Name;
                        ToolTip = 'Specifies the journal template that the item journal is based on.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ItemJnlTemplate: Record "Item Journal Template";
                            ItemJnlTemplates: Page "Item Journal Templates";
                        begin
                            ItemJnlTemplate.SetRange(Type, ItemJnlTemplate.Type::Item);
                            ItemJnlTemplate.SetRange(Recurring, false);
                            ItemJnlTemplates.SetTableView(ItemJnlTemplate);

                            ItemJnlTemplates.LookupMode := true;
                            ItemJnlTemplates.Editable := false;
                            if ItemJnlTemplates.RunModal() = ACTION::LookupOK then begin
                                ItemJnlTemplates.GetRecord(ItemJnlTemplate);
                                JournalTemplate := ItemJnlTemplate.Name;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            CheckJournalTemplate();
                        end;
                    }
                    field(BatchName; BatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch Name';
                        ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ItemJnlBatches: Page "Item Journal Batches";
                        begin
                            if JournalTemplate <> '' then begin
                                ItemJnlBatch.SetRange("Journal Template Name", JournalTemplate);
                                ItemJnlBatches.SetTableView(ItemJnlBatch);
                            end;

                            ItemJnlBatches.LookupMode := true;
                            ItemJnlBatches.Editable := false;
                            if ItemJnlBatches.RunModal() = ACTION::LookupOK then begin
                                ItemJnlBatches.GetRecord(ItemJnlBatch);
                                BatchName := ItemJnlBatch.Name;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            CheckBatchName();
                        end;
                    }
                    field(TemplateCode; TemplateCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Standard Item Journal';
                        TableRelation = "Standard Item Journal".Code;
                        ToolTip = 'Specifies the standard item journal that the batch job uses.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            StdItemJnl1: Record "Standard Item Journal";
                            StdItemJnls: Page "Standard Item Journals";
                        begin
                            if JournalTemplate <> '' then begin
                                StdItemJnl1.SetRange("Journal Template Name", JournalTemplate);
                                StdItemJnls.SetTableView(StdItemJnl1);
                            end;

                            StdItemJnls.LookupMode := true;
                            StdItemJnls.Editable := false;
                            if StdItemJnls.RunModal() = ACTION::LookupOK then begin
                                StdItemJnls.GetRecord(StdItemJnl1);
                                TemplateCode := StdItemJnl1.Code;
                            end;
                        end;
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate();
        end;
    }

    trigger OnPostReport()
    begin
        Commit();
        ItemJournal.SetRecord(ItemJnlLine);
        ItemJournal.RunModal();
    end;

    var
        EntryTypes: Option Purchase,Sale,"Positive Adjmt.","Negative Adjmt.";
        ItemJournal: Page "Item Journal";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        StdItemJnl: Record "Standard Item Journal";
        LastItemJnlLine: Record "Item Journal Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        LineNo: Integer;
        PostingDate: Date;
        DocumentDate: Date;
        JournalTemplate: Text[10];
        TaskId: Integer;
        BatchName: Code[10];
        DocumentNo: Code[20];
        TemplateCode: Code[20];
        PostingDateIsEmptyErr: Label 'The Posting Date is empty.';
        Text001: Label 'Item Journal Template name is blank.';
        Text002: Label 'Item Journal Batch name is blank.';

    local procedure GetStandardJournalLine(): Boolean
    var
        StdItemJnlLine: Record "Standard Item Journal Line";
    begin
        if TemplateCode = '' then
            exit;
        StdItemJnlLine.SetRange("Journal Template Name", StdItemJnl."Journal Template Name");
        StdItemJnlLine.SetRange("Standard Journal Code", StdItemJnl.Code);
        exit(not StdItemJnlLine.IsEmpty());
    end;

    local procedure CheckPostingDate()
    begin
        if PostingDate = 0D then
            Error(PostingDateIsEmptyErr);
    end;

    local procedure CheckJournalTemplate()
    begin
        if JournalTemplate = '' then
            Error(Text001);
    end;

    local procedure CheckBatchName()
    begin
        if BatchName = '' then
            Error(Text002);
    end;

    procedure Initialize(StdItemJnl: Record "Standard Item Journal"; JnlBatchName: Code[10])
    begin
        ItemJnlLine."Journal Template Name" := StdItemJnl."Journal Template Name";
        ItemJnlLine."Journal Batch Name" := JnlBatchName;
        ItemJnlLine.SetRange("Journal Template Name", StdItemJnl."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", JnlBatchName);

        LastItemJnlLine.SetRange("Journal Template Name", StdItemJnl."Journal Template Name");
        LastItemJnlLine.SetRange("Journal Batch Name", JnlBatchName);

        if LastItemJnlLine.FindLast() then;
    end;

    local procedure CopyItemJnlFromStdJnl(StdItemJnlLine: Record "Standard Item Journal Line"; var ItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine.Init();
        ItemJnlLine."Line No." := 0;
        ItemJnlLine.SetUpNewLine(LastItemJnlLine);
        if LastItemJnlLine."Line No." <> 0 then
            ItemJnlLine."Line No." := LastItemJnlLine."Line No." + 10000
        else
            ItemJnlLine."Line No." := 10000;

        ItemJnlLine.TransferFields(StdItemJnlLine, false);

        if (ItemJnlLine."Item No." <> '') and (ItemJnlLine."Unit Amount" = 0) then
            ItemJnlLine.RecalculateUnitAmount();

        if (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Output) and
           (ItemJnlLine."Value Entry Type" <> ItemJnlLine."Value Entry Type"::Revaluation)
        then
            ItemJnlLine."Invoiced Quantity" := 0
        else
            ItemJnlLine."Invoiced Quantity" := ItemJnlLine.Quantity;
        ItemJnlLine.TestField("Qty. per Unit of Measure");
        ItemJnlLine."Invoiced Qty. (Base)" :=
          Round(ItemJnlLine."Invoiced Quantity" * ItemJnlLine."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision());

        ItemJnlLine.Insert(true);

        LastItemJnlLine := ItemJnlLine;
    end;

    procedure SetTaskId(Id: Integer)
    begin
        TaskId := Id;
    end;
}