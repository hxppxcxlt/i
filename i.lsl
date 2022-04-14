key Owner;
integer Channel;
integer Listener;
integer ListenerDuration;

list FoundNames1;
list FoundNames2;
integer FoundTotal;
integer NotFound;

startListener()
{
    ListenerDuration = 0;
    if (Listener == 0) {
        Listener = llListen(Channel, "", Owner, "");
        llSetTimerEvent(1);
    }
}

stopListener()
{
    llSetTimerEvent(0);
    llListenRemove(Listener);
    Listener = 0;
    ListenerDuration = 0;
}

string profileLink(key uuid)
{
    return "[ secondlife:///app/agent/" + (string) uuid + "/about ]";
}

listAvatar(key uuid)
{
    llOwnerSay("█▓▒░░░▒▓██▓▒░░░▒▓█ " + profileLink(uuid) + " █▓▒░░░▒▓██▓▒░░░▒▓█");

    integer object = 0;
    list uuids = llGetAttachedList(uuid);
    list names;
    list creators;
    while (object < llGetListLength(uuids))
    {
        names = llGetObjectDetails(llList2Key(uuids, object), [OBJECT_NAME]);
        creators = llGetObjectDetails(llList2Key(uuids, object), [OBJECT_CREATOR]);
        llOwnerSay(llList2String(names, 0) + " " + profileLink(llList2String(creators, 0)));
        object++;
    }

    stopListener();
}

other()
{
    string status = "\npaste in an avatar uuid\n";
    if (NotFound == TRUE) status += "\nthe avatar was not found in the region, try again\n";
    else status += "\nthe avatar must be in the same region as you\n";

    NotFound = FALSE;

    llTextBox(Owner, status, Channel);
}

page1()
{
    startListener();

    string status = "\nlook at who? (1/1)\n\n";
    if (FoundTotal > 9) status = "\nlook at who? (1/2)\n\n";

    integer user = 0;
    integer list_pos = 0;
    while (user < llList2Integer(FoundNames1, 0)) {
        status += llList2String(FoundNames1, list_pos + 1) + "\n";
        user++;
        list_pos += 2;
    }

    list choices = ["OTHER", "REFRESH"];
    if (FoundTotal > 9) choices += "PAGE 2";
    else choices += " ";
    if (FoundTotal > 6) choices += "7.";
    else choices += " ";
    if (FoundTotal > 7) choices += "8.";
    else choices += " ";
    if (FoundTotal > 8) choices += "9.";
    else choices += " ";
    if (FoundTotal > 3) choices += "4.";
    else choices += " ";
    if (FoundTotal > 4) choices += "5.";
    else choices += " ";
    if (FoundTotal > 5) choices += "6.";
    else choices += " ";
    if (FoundTotal > 0) choices += "1.";
    else choices += " ";
    if (FoundTotal > 1) choices += "2.";
    else choices += " ";
    if (FoundTotal > 2) choices += "3.";
    else choices += " ";

    llDialog(Owner, status, choices, Channel);
}

page2()
{
    ListenerDuration = 0;

    string status = "\nlook at who? (2/2)\n\n";

    integer user = 0;
    integer list_pos = 0;
    while (user < llList2Integer(FoundNames2, 0)) {
        status += llList2String(FoundNames2, list_pos + 1) + "\n";
        user++;
        list_pos += 2;
    }

    list choices = ["OTHER", "REFRESH", "PAGE 1"];
    if (FoundTotal > 15) {
        choices += " ";
        choices += "16.";
        choices += " ";
    } else {
        choices += " ";
        choices += " ";
        choices += " ";
    }
    if (FoundTotal > 12) choices += "13.";
    else choices += " ";
    if (FoundTotal > 13) choices += "14.";
    else choices += " ";
    if (FoundTotal > 14) choices += "15.";
    else choices += " ";
    if (FoundTotal > 9) choices += "10.";
    else choices += " ";
    if (FoundTotal > 10) choices += "11.";
    else choices += " ";
    if (FoundTotal > 11) choices += "12.";
    else choices += " ";

    llDialog(Owner, status, choices, Channel);
}

default
{
    state_entry()
    {
        Owner = llGetOwner();
        Channel = ((integer) ("0x" + llGetSubString((string) llGetKey(), -8, -1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF;

        if (llGetObjectName() == "Object") {
            llSetLinkPrimitiveParams(0, [
                PRIM_NAME, "i",
                PRIM_DESC, "https://github.com/hxppxcxlt/i",
                PRIM_SIZE, <0.01, 0.08, 0.045>,
                PRIM_TYPE, PRIM_TYPE_BOX, 0, <0.0,1.0,0.0>, 0.0, ZERO_VECTOR, <1.0, 1.0, 0.0>, ZERO_VECTOR,
                PRIM_TEXTURE, ALL_SIDES, TEXTURE_BLANK, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
                PRIM_COLOR, ALL_SIDES, ZERO_VECTOR, 1.0,
                PRIM_FULLBRIGHT, ALL_SIDES, FALSE,
                PRIM_TEXTURE, 4, "306b3888-7c55-696d-0b4b-588a05547f92", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
                PRIM_COLOR, 4, <1.0, 1.0, 1.0>, 1.0,
                PRIM_FULLBRIGHT, 4, TRUE
            ]);
        }
    }

    on_rez(integer start_param) { llResetScript(); }

    sensor(integer detected)
    {
        FoundTotal = detected;

        if (detected <= 9) FoundNames1 = [detected];
        else FoundNames1 = [9];
        if (detected > 9) FoundNames2 = [detected - 9];
        else FoundNames2 = [0];

        integer user = 0;
        integer button_label = 1;
        key uuid;
        string legacy_name;
        string display_name;
        string counter;
        string name;
        while(detected--) {
            uuid = llDetectedKey(detected);
            legacy_name = llDetectedName(detected);
            display_name = llGetDisplayName(uuid);

            counter = (string) button_label + ".";
            name = counter + " " + legacy_name;
            if (display_name) name = counter + ": " + display_name + " (" + legacy_name + ")";

            if (user < 9) {
                FoundNames1 += name;
                FoundNames1 += uuid;
            } else {
                FoundNames2 += name;
                FoundNames2 += uuid;
            }

            user++;
            button_label++;
        }

        page1();
    }

    no_sensor()
    {
        startListener();
        llDialog(Owner, "\nthere are no others in range\n\n", ["OTHER", "REFRESH"], Channel);
    }

    touch_start(integer total_number) { llSensor("", "", AGENT, 96.0, PI); }

    listen(integer chan, string name, key id, string msg)
    {
        if (msg == "REFRESH" || msg == "PAGE 1") llSensor("", "", AGENT, 96.0, PI);
        else if (msg == "PAGE 2") page2();
        else if (msg == "OTHER") other();
        else if (msg == "0.") listAvatar(Owner);
        else if (msg == "1.") listAvatar(llList2Key(FoundNames1, 2));
        else if (msg == "2.") listAvatar(llList2Key(FoundNames1, 4));
        else if (msg == "3.") listAvatar(llList2Key(FoundNames1, 6));
        else if (msg == "4.") listAvatar(llList2Key(FoundNames1, 8));
        else if (msg == "5.") listAvatar(llList2Key(FoundNames1, 10));
        else if (msg == "6.") listAvatar(llList2Key(FoundNames1, 12));
        else if (msg == "7.") listAvatar(llList2Key(FoundNames1, 14));
        else if (msg == "8.") listAvatar(llList2Key(FoundNames1, 16));
        else if (msg == "9.") listAvatar(llList2Key(FoundNames1, 18));
        else if (msg == "10.") listAvatar(llList2Key(FoundNames2, 2));
        else if (msg == "11.") listAvatar(llList2Key(FoundNames2, 4));
        else if (msg == "12.") listAvatar(llList2Key(FoundNames2, 6));
        else if (msg == "13.") listAvatar(llList2Key(FoundNames2, 8));
        else if (msg == "14.") listAvatar(llList2Key(FoundNames2, 10));
        else if (msg == "15.") listAvatar(llList2Key(FoundNames2, 12));
        else if (msg == "16.") listAvatar(llList2Key(FoundNames2, 14));
        else {
            if (llKey2Name(msg) == "") {
                NotFound = TRUE;
                other();
            } else listAvatar(msg);
        }
    }

    timer()
    {
        if (ListenerDuration == 60) stopListener();
        else ListenerDuration++;
    }
}

