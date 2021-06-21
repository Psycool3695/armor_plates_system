#include "script_component.hpp"
[
    player,
    "Give up",
    "\A3\Ui_f\data\IGUI\Cfg\Revive\overlayIcons\d50_ca.paa",
    "\A3\Ui_f\data\IGUI\Cfg\Revive\overlayIcons\d100_ca.paa",
    "alive _target && {(lifeState _target) == 'INCAPACITATED' && {_target isEqualTo (call CBA_fnc_currentUnit)}}",
    "alive _target",
    {},
    {},{
        params ["_target", ""];
        [QGVAR(setHidden), [_target , false]] call CBA_fnc_localEvent;
        _target setDamage 1;
    },
    {},
    [],
    3,
    1000,
    true,
    true
] call BIS_fnc_holdActionAdd;

// workaround for mods or missions healing the default a3 damage while the internal health is not at max
private _id = player addAction ["<img image='\A3\ui_f\data\igui\cfg\actions\heal_ca.paa' size='1.8' shadow=2 />", {
    params ["_target"];
    private _healItem = [_target] call FUNC(hasHealItems);
    if (_healItem isEqualTo 1) then {
        _target removeItem "FirstAidKit";
    };
    private _isProne = stance _target == "PRONE";
    private _medicAnim = ["AinvPknlMstpSlayW[wpn]Dnon_medic", "AinvPpneMstpSlayW[wpn]Dnon_medic"] select _isProne;
    private _wpn = ["non", "rfl", "lnr", "pst"] param [["", primaryWeapon _target, secondaryWeapon _target, handgunWeapon _target] find currentWeapon _target, "non"];
    _medicAnim = [_medicAnim, "[wpn]", _wpn] call CBA_fnc_replace;
    if (_medicAnim != "") then {
        _target playMove _medicAnim;
    };
    [{
        params ["_target"];
        if (!alive _target || {_target getVariable [QGVAR(unconscious), false]}) exitWith {};
        [QGVAR(heal), [_target, _target]] call CBA_fnc_localEvent;
    }, _this, 5] call CBA_fnc_waitAndExecute;
}, [], 10, true, true, "", format ["alive _target && {_originalTarget isEqualTo _this && {(damage _target) isEqualTo 0 && {(_target getVariable ['%1' , %2]) < (%2 * ([%4, %5] select (_target getUnitTrait 'Medic'))) && {([_target] call %3) > 0}}}}", QGVAR(hp), QGVAR(maxPlayerHP), QFUNC(hasHealItems), QGVAR(maxHealRifleman), QGVAR(maxHealMedic)], 2];
player setUserActionText [_id, localize "str_a3_cfgactions_healsoldierself0", "<img image='\A3\ui_f\data\igui\cfg\actions\heal_ca.paa' size='1.8' shadow=2 />"];
