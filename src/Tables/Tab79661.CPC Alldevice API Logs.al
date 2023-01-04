table 79661 "CPC Alldevice API Logs"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "CPC Entry Time"; DateTime)
        {
            Caption = 'Entry Time';
            DataClassification = CustomerContent;
        }
        field(3; "CPC Response JSON Data"; Blob)
        {
            Caption = 'Response JSON Data';
            DataClassification = CustomerContent;
        }
        field(4; "CPC API Request Sucess"; Boolean)
        {
            Caption = 'API Request Sucess';
            DataClassification = CustomerContent;
        }
        field(5; "CPC Sent JSON Data"; Blob)
        {
            Caption = 'Sent JSON Data';
            DataClassification = CustomerContent;
        }
        field(6; "CPC Address Prefix"; Text[50])
        {
            Caption = 'Address Prefix';
            DataClassification = CustomerContent;
        }
        field(7; "CPC Error From BC"; Text[250])
        {
            Caption = 'Error From BC';
            DataClassification = ToBeClassified;
        }
        field(8; "CPC Additional Information"; Text[250])
        {
            Caption = 'Additional Information';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        LockTable(true);
        AlldeviceAPILogs.Reset();
        if AlldeviceAPILogs.FindLast() then
            Rec."Entry No." := AlldeviceAPILogs."Entry No." + 1
        else
            "Entry No." := 1;
    end;

    procedure CreateApiLog(var RequestJson: JsonObject; var ResponseJson: JsonObject; SentToAddressPrefix: Text; RequestSucess: Boolean; BcError: Text; AdditionalInfo: Text)
    var
        ResponseJsonOutStream: OutStream;
        SentJsonOutStream: OutStream;
    begin
        Rec.Init();
        Rec."CPC Entry Time" := CurrentDateTime();

        Rec."CPC Response JSON Data".CreateOutStream(ResponseJsonOutStream);
        ResponseJson.WriteTo(ResponseJsonOutStream);

        Rec."CPC API Request Sucess" := RequestSucess;

        Rec."CPC Sent JSON Data".CreateOutStream(SentJsonOutStream);
        RequestJson.WriteTo(SentJsonOutStream);

        Rec."CPC Address Prefix" := SentToAddressPrefix;
        Rec."CPC Error From BC" := BcError;
        Rec."CPC Additional Information" := AdditionalInfo;
        Rec.Insert(true);
    end;

    procedure OpenResponseJson()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        CALCFIELDS("CPC Response JSON Data");
        if "CPC Response JSON Data".HASVALUE then begin
            TempBlob.FromRecord(Rec, FieldNo("CPC Response JSON Data"));
            FileMgt.BLOBExport(TempBlob, '*.json', true);
        end else
            FIELDERROR("CPC Response JSON Data");
    end;

    procedure OpenSentJson()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        CALCFIELDS("CPC Sent JSON Data");
        if "CPC Sent JSON Data".HASVALUE then begin
            TempBlob.FromRecord(Rec, FieldNo("CPC Sent JSON Data"));
            FileMgt.BLOBExport(TempBlob, '*.json', true);
        end else
            FIELDERROR("CPC Sent JSON Data");
    end;

    var
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";
}