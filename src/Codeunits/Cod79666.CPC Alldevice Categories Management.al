codeunit 79667 "CPC Alldevice Cat. Mngmt."
{
    trigger OnRun()
    begin
        AlldeviceAPISetup.Get();

        if AddOrModifyItemCat then begin
            AddOrModifyItemCategoryToAlldevice();
            exit;
        end;

        CheckIfCategoryExsists();

        if NewCategoryAdd then
            AddNewCategoryToBC()
        else
            ModifyExistingCategoryInBC();

        ClearAll();
    end;

    var
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        NewCategoryAdd: Boolean;
        CategoryCode: Code[20];
        CategoryJsonObject: JsonObject;
        ItemCategory: Record "Item Category";
        AlldeviceAPILogs: Record "CPC Alldevice API Logs";
        AddOrModifyItemCat: Boolean;

    procedure SetParameters(JsonObj: JsonObject)
    begin
        CategoryJsonObject := JsonObj;
    end;

    local procedure AddNewCategoryToBC()
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.Init();
        ItemCategory.Validate(Code, AlldeviceAPIManagement.GetJsonToken(CategoryJsonObject, 'name').AsValue().AsCode());
        ItemCategory.Validate("Parent Category", AlldeviceAPISetup."CPC Main Category");
        ItemCategory."CPC Alldevice Category Id" := AlldeviceAPIManagement.GetJsonToken(CategoryJsonObject, 'cat_id').AsValue().AsInteger();
        ItemCategory.Insert(true);
    end;

    procedure SetAddOrModifyItemCatParam(AddOrModify: Boolean; ItemCatToAlldevice: Record "Item Category")
    begin
        AddOrModifyItemCat := AddOrModify;
        ItemCategory := ItemCatToAlldevice;
    end;

    local procedure CheckIfCategoryExsists()
    var
        ItemCategory: Record "Item Category";
    begin
        if ItemCategory.Get(AlldeviceAPIManagement.GetJsonToken(CategoryJsonObject, 'name').AsValue().AsCode()) then begin
            // If product already exists, update it if needed.
            NewCategoryAdd := false;
            CategoryCode := ItemCategory.Code;
        end else begin
            // Add new product.
            NewCategoryAdd := true;
        end;
    end;

    local procedure AddOrModifyItemCategoryToAlldevice()
    var
        RequestJson: JsonObject;
        ResponseJson: JsonObject;
        NewOrModifiedCategoryObject: JsonObject;
    begin
        RequestJson := AlldeviceAPIManagement.GetRequestJsonWithAuth();

        RequestJson.Add('name', ItemCategory.Code);
        RequestJson.Add('cat_id', ItemCategory."CPC Alldevice Category Id");

        ResponseJson := AlldeviceAPIManagement.PostRequest(AlldeviceAPISetup."CPC Update or add Cat. Prefix", RequestJson);

        if AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'success').AsValue().AsBoolean() = true then begin
            NewOrModifiedCategoryObject := AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'response').AsObject();
            ItemCategory."CPC Alldevice Category Id" := AlldeviceAPIManagement.GetJsonToken(NewOrModifiedCategoryObject, 'cat_id').AsValue().AsInteger();
            ItemCategory."CPC Last Synced To Alldevice" := CurrentDateTime();
            ItemCategory.Modify(true);

            AlldeviceAPILogs.CreateApiLog(RequestJson, ResponseJson, AlldeviceAPISetup."CPC Update or add Cat. Prefix", true, '', '');
        end else begin
            AlldeviceAPILogs.CreateApiLog(RequestJson,
                                            ResponseJson,
                                            AlldeviceAPISetup."CPC Update or add Cat. Prefix",
                                            false,
                                            '',
                                            AlldeviceAPIManagement.GetJsonToken(ResponseJson, 'message').AsValue().AsText());
        end;
    end;

    local procedure ModifyExistingCategoryInBC()
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.Get(CategoryCode);

        if ItemCategory."CPC Alldevice Category Id" <> AlldeviceAPIManagement.GetJsonToken(CategoryJsonObject, 'cat_id').AsValue().AsInteger() then
            ItemCategory."CPC Alldevice Category Id" := AlldeviceAPIManagement.GetJsonToken(CategoryJsonObject, 'cat_id').AsValue().AsInteger();

        ItemCategory.Modify();
    end;
}