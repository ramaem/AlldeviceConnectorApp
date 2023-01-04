codeunit 79660 "CPC Alldevice API Management"
{
    procedure GetRequestJsonWithAuth(): JsonObject
    var
        JsonObject: JsonObject;
        AuthJsonObject: JsonObject;
    begin
        AlldeviceAPISetup.Get();

        AuthJsonObject.Add('username', AlldeviceAPISetup."CPC Alldevice API Username");
        AuthJsonObject.Add('password', AlldeviceAPISetup."CPC Alldevice API Password");
        AuthJsonObject.Add('key', AlldeviceAPISetup."CPC Alldevice API Key");

        JsonObject.Add('auth', AuthJsonObject);

        exit(JsonObject);
    end;

    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, Jsontoken) then
            Error(Error001, TokenKey);
    end;

    procedure SelectJsonToken(JsonObject: JsonObject; Path: Text) JsonToken: JsonToken
    begin
        if not JsonObject.SelectToken(Path, JsonToken) then
            Error(Error002, Path);
    end;

    procedure GetList(Prefix: Text) ResponseText: Text
    var
        AlldeviceAPIManagement: Codeunit "CPC Alldevice API Management";
        RequestJson: JsonObject;
        RequestJsonText: Text;
        Client: HttpClient;
        Response: HttpResponseMessage;
        Body: Text;
        Content: HttpContent;
        RequestURL: Text;
    begin
        AlldeviceAPISetup.Get();
        RequestJson := AlldeviceAPIManagement.GetRequestJsonWithAuth();
        RequestJson.WriteTo(RequestJsonText);
        Content.WriteFrom(RequestJsonText);
        RequestURL := AlldeviceAPISetup."CPC Alldevice API URL" + Prefix;
        Client.Post(RequestURL, Content, Response);
        Response.Content.ReadAs(ResponseText);
    end;

    procedure PostRequest(Prefix: Text; var RequestJson: JsonObject) ResponseJson: JsonObject
    var
        ResponseText: Text;
        RequestJsonText: Text;
        RequestURL: Text;
        Content: HttpContent;
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        AlldeviceAPISetup.Get();
        RequestJson.WriteTo(RequestJsonText);
        Content.WriteFrom(RequestJsonText);
        RequestURL := AlldeviceAPISetup."CPC Alldevice API URL" + Prefix;
        Client.Post(RequestURL, Content, Response);
        Response.Content.ReadAs(ResponseText);
        ResponseJson.ReadFrom(ResponseText);
    end;

    var
        AlldeviceAPISetup: Record "CPC Alldevice API Setup";
        Error001: Label 'Could not find a token with key %1', Locked = true;
        Error002: Label 'Could not find a token with path %1', Locked = true;
}