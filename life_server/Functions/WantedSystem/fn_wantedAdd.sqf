/*
    File: fn_wantedAdd.sqf
    Author: Bryan "Tonic" Boardwine"
    Database Persistence By: ColinM
    Assistance by: Paronity
    Stress Tests by: Midgetgrimm

    Description:
    Adds or appends a unit to the wanted list.
*/
params [
    ["_uid","",[""]],
    ["_name","",[""]],
    ["_type","",[""]],
    ["_customBounty",-1,[0]]
];

if (_uid isEqualTo "" || {_type isEqualTo "" || _name isEqualTo ""}) exitWith {}; //Bad data passed.

//What is the crime?
private _crimesConfig = getArray(missionConfigFile >> "Life_Settings" >> "crimes");
private _index = [_type,_crimesConfig] call TON_fnc_index;

if (_index isEqualTo -1) exitWith {};

_type = [_type, parseNumber ((_crimesConfig select _index) select 1)];

if (count _type isEqualTo 0) exitWith {}; //Not our information being passed...
//Is there a custom bounty being sent? Set that as the pricing.
if !(_customBounty isEqualTo -1) then {_type set[1,_customBounty];};

//Search the wanted list to make sure they are not on it.
if !(count ([format ["SELECT wantedID FROM wanted WHERE wantedID='%1'",_uid],2,true] call DB_fnc_asyncCall) isEqualTo 0) then {
    _pastCrimes = [([format ["SELECT wantedCrimes, wantedBounty FROM wanted WHERE wantedID='%1'",_uid],2] call DB_fnc_asyncCall) select 0] call DB_fnc_mresToArray;

    if (_pastCrimes isEqualType "") then {_pastCrimes = call compile format ["%1", _pastCrimes];};
    _pastCrimes pushBack (_type select 0);
    _pastCrimes = [_pastCrimes] call DB_fnc_mresArray;
    [format ["UPDATE wanted SET wantedCrimes = '%1', wantedBounty = wantedBounty + '%2', active = '1' WHERE wantedID='%3'", _pastCrimes, [_type select 1] call DB_fnc_numberSafe, _uid], 1] call DB_fnc_asyncCall;
} else {
    _crime = [_type select 0];
    _crime = [_crime] call DB_fnc_mresArray;
    [format ["INSERT INTO wanted (wantedID, wantedName, wantedCrimes, wantedBounty, active) VALUES('%1', '%2', '%3', '%4', '1')", _uid, _name, _crime, [_type select 1] call DB_fnc_numberSafe], 1] call DB_fnc_asyncCall;
};
