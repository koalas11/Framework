#include "\life_server\script_macros.hpp"
/*
    File: fn_chopShopSell.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Checks whether or not the vehicle is persistent or temp and sells it.
*/
params [
    ["_newuid","",[""]],
    ["_vehicle",objNull,[objNull]]
];

//Error checks
if (isNull _vehicle || {_newuid isEqualTo ""}) exitWith  {};

private _dbInfo = _vehicle getVariable ["dbInfo",[]];
if (count _dbInfo > 0) then {
    _dbInfo params [["_uid","",[""]],["_plate",-1,[0]]];
    [format ["UPDATE vehicles SET pid='%1' WHERE pid='%2' AND plate='%3'",_newuid,_uid,_plate],1] call DB_fnc_asyncCall;
};

titleText ["The Vehicle is now yours.","PLAIN"];