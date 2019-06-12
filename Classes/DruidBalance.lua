-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {            
            aura = "fury_of_elune_ap",

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        natures_balance = {
            talent = "natures_balance",

            last = function ()
                local app = state.combat
                local t = state.query_time

                return app + floor( ( t - app ) / 1.5 ) * 1.5
            end,

            interval = 1.5, -- actually 0.5 AP every 0.75s, but...
            value = 1,
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )

    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        shooting_stars = 21648, -- 202342
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3543, -- 214027
        relentless = 3542, -- 196029
        gladiators_medallion = 3541, -- 208683

        celestial_downpour = 183, -- 200726
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        cyclone = 857, -- 209753
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        ironfeather_armor = 1216, -- 233752
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 236696
    } )


    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        blessing_of_cenarius = {
            id = 238026,
            duration = 60,
            max_stack = 1,
        },
        blessing_of_the_ancients = {
            id = 206498,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = 20,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flask_of_the_seventh_demon = {
            id = 188033,
            duration = 3600.006,
            max_stack = 1,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            max_stack = 1,

            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast

                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end

                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102560,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        legionfall_commander = {
            id = 233641,
            duration = 3600,
            max_stack = 1,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 22,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )

                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = function () return pvptalent.celestial_downpour.enabled and 16 or 8 end,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_drift = {
            id = 202461,
            duration = 3600,
            max_stack = 1,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thorny_entanglement = {
            id = 241750,
            duration = 15,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        arcanic_pulsar = {
            id = 287790,
            duration = 3600,
            max_stack = 9,
        },

        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },
    } )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        removeBuff( "celestial_guardian" )
    end )


    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end 
    end )


    local check_for_ap_overcap = setfenv( function( ability )
        local a = ability or this_action
        if not a then return true end

        a = action[ a ]
        if not a then return true end

        local cost = 0
        if a.spendType == "astral_power" then cost = a.cost end

        return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
    end, state )

    spec:RegisterStateExpr( "ap_check", function() return check_for_ap_overcap() end )
    
    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = { 
        "force_of_nature", "full_moon", "half_moon", "incarnation", "lunar_strike", "moonfire", "new_moon", "solar_wrath", "starfall", "starsurge", "sunfire"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end
    

    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 ) 
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end )


    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'solar_solstice', {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } ) 

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )    
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },    
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )



    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,

            handler = function ()
                applyBuff( "barkskin" )
            end,
        },


        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",

            handler = function ()
                shift( "bear_form" )
            end,
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            noform = "cat_form",

            handler = function ()
                shift( "cat_form" )
            end,
        },


        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "celestial_alignment" )
                gain( 40, "astral_power" )
                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",

            spend = 0.15,
            spendType = "mana",

            startsCombat = true,
            texture = 136022,

            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },


        --[[ dreamwalk = {
            id = 193753,
            cast = 10,
            cooldown = 60,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135763,

            handler = function ()
            end,
        }, ]]


        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.18,
            spendType = "mana",

            startsCombat = false,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,

            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            talent = "feral_affinity",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },


        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132925,

            handler = function ()
            end,
        }, ]]


        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",

            ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

            handler = function ()
                summonPet( "treants", 10 )
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },


        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",

            ap_check = function() return check_for_ap_overcap( "full_moon" ) end,

            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },


        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        half_moon = {
            id = 274282, 
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",

            ap_check = function() return check_for_ap_overcap( "half_moon" ) end,

            usable = function () return active_moon == 'half_moon' end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                shift( "moonkin_form" )
                
                applyBuff( "incarnation" )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "incarnation_chosen_of_elune"
        },


        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,

            usable = function () return group end,
            handler = function ()
                active_dot.innervate = 1
            end,
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 45,
            spendType = "rage",

            startsCombat = true,
            texture = 1378702,

            handler = function ()
                applyBuff( "ironfur" )
            end,
        },


        lunar_strike = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up then return 0 end
                return haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -12 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135753,            

            ap_check = function() return check_for_ap_overcap( "lunar_strike" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )

                if buff.warrior_of_elune.up then
                    removeStack( "warrior_of_elune" )
                    if buff.warrior_of_elune.down then
                        setCooldown( "warrior_of_elune", 45 ) 
                    end
                end

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = -8,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
            end,
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",

            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",

            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -3,
            spendType = "astral_power",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
            end,
        },


        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        new_moon = {
            id = 274281, 
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,

            talent = "new_moon",
            bind = "full_moon",

            ap_check = function() return check_for_ap_overcap( "new_moon" ) end,

            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = true,
            texture = 514640,

            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },


        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 136080,

            handler = function ()
            end,
        }, ]]


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.11,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 135952,

            handler = function ()
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                -- unshift?
                gain( 0.3 * health.max, "health" )
            end,
        },


        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        }, ]]


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
            end,
        },


        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            spend = 0.17,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },


        solar_wrath = {
            id = 190984,
            cast = function () return haste * ( buff.solar_empowerment.up and 0.85 or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function() return check_for_ap_overcap( "solar_wrath" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "solar_empowerment" )
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeBuff( "dispellable_enrage" )
            end,
        },


        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
            end,
        },


        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.oneths_overconfidence.up then return 0 end
                return talent.soul_of_the_forest.enabled and 40 or 50
            end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_overconfidence" )
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
            end,
        },


        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.oneths_intuition.up then return 0 end
                return 40 - ( buff.the_emerald_dreamcatcher.stack * 5 )
            end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,   

            handler = function ()
                addStack( "lunar_empowerment", nil, 1 )
                addStack( "solar_empowerment", nil, 1 )
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_intuition" )
                removeBuff( "sunblaze" )

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment" )
                    end
                end

                if ( level < 116 and equipped.the_emerald_dreamcatcher ) then addStack( "the_emerald_dreamcatcher", 5, 1 ) end
            end,
        },


        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",

            ap_check = function() return check_for_ap_overcap( "stellar_flare" ) end,

            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },


        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.12,
            spendType = "mana",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            

            handler = function ()
                gain( 3, "astral_power" )
                applyDebuff( "target", "sunfire" )
            end,
        },


        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",            

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },

        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe = {
            known = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,

            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { 106785, 213771 }
        },


        thrash = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },


        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136104,

            handler = function ()
                applyBuff( "thorns" )
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },


        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132145,

            handler = function ()
                shift( "treant_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "typhoon",

            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },


        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 538771,

            talent = "wild_charge",

            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 6,

        potion = "potion_of_rising_death",

        package = "Balance",        
    } )


    spec:RegisterPack( "Balance", 20190420.1707, [[dGe5Raqii0JaixseL2evPpPikJsr1PaWQavYROeMfLIBPOu7Ik)ccgMiLJrjAzusEMIW0ue5AusX2er13aOACGk15OKQwhaLEhafnpqf3dI2hLkhKskTqrKhQOKMOik6IkIkTrruiFuefQtQiQALIKzkIc2jLslvruXtbzQuQAVu8xrnyvomPfdPhJyYeCzuBwHpdkJMQ40kTAak8Ary2eDBQQDRQFJ0Wj0XvuILl1ZHA6cxhOTdQ67ksJNsQCErQwVII5dO9lzJLg7nqcAWgBTknlT(0MKvP5SeWtZ6T0kduKUiBGevscfgBGE1NnqjPs9jSbsutxsvbJ9gimfSjSbYteIyalciaBdpGOoc1hb86dk1yPpP1rGaE9jiyGqbxzm5FdQbsqd2yRvPzP1N2KSknNLaEAWT1yLbsbdp02abT(ZQbYZkiWVb1ajWyIbcq1LKk1NW1LmBWvOsbO68eHigWIacW2WdiQJq9raV(Gsnw6tADeiGxFccvkavN1k2RSoRsZM6SknlT(6MDDwc4a20a8kvLcq1nRE0hgJbSvkav3SRZAfeyH6GOsTRljw9Dvkav3SRBw9OpmwOUqByCK3rDefZ46cADK0jsohAdJdSRsbO6MDDwRaGbioyH6WJCOnmoW1bV2RIk56g0UovqG(1Ht)d16Cvkav3SRdA9fL7i96S2z4EdUUO1nQtsPjafX1nxG(twuhiMRd8FMWyS2Pxh8AVkQKRdN(hQ1bGRsbO6MDDtoSpfEwOUKHfEwMEDqIBVrDe6lSXs)6g0UUzLLmowvwN1kxyVp)bGzDPtbNmPSopk8CDBuhTRlDkyDtP)Kf1H3NW1n5)NB41GRBX15zH5H76e7L2BKUZajxCGn2BGe4HckdJ9gBT0yVbsjXsFdeMk1oJYQVbIFfvYcMKmHXwRm2BG4xrLSGjjdeP3G7vnqOGJHJO59jUM919X1zxDjVoV1PKyHNZ8Z(lJRdzDwAGusS03ajsJL(MWy7eg7nq8ROswWKKbI0BW9QgiuWXWr08(exZ(6(46SRUKBGePXsFdeQgHKZI0yPFMoY7hSuYKWaPKyPVbsKgl9nHX2jzS3aXVIkzbtsgisVb3RAGqbhdhrZ7tCGIgiLel9nqOskvipa70nHXwRXyVbIFfvYcMKmqKEdUx1aHcogoIM3N4afnqkjw6BGq5gZDI9HzcJTj3yVbIFfvYcMKmqKEdUx1aHcogoIM3N4afnqkjw6BG0MOpNdA38hMWylGBS3aXVIkzbtsgisVb3RAGqbhdhrZ7tCGIgiLel9nqYfMNaNbmafG5ZFycJTWTXEde)kQKfmjzGi9gCVQbcfCmCenVpXbkAGusS03an2MrLuQGjm2A9g7nq8ROswWKKbI0BW9QgiuWXWr08(ehOObsjXsFdK(eghTkZevknHXwltZyVbIFfvYcMKmqkjw6BGqvjp2MZOT(epgisVb3RAG4zbCffzbhQk5X2CgT1N4PoV1rOuPaD67iAEFIRzFDFCD2v3ePzGE1NnqOQKhBZz0wFIhtyS1sln2BG4xrLSGjjdKsIL(giHMvHmmPkSAqBCgvfGXgisVb3RAG4zbCffzbNqZQqgMufwnOnoJQcW468whHsLc0PVJO59jUM919X1zxDtKMb6vF2aj0SkKHjvHvdAJZOQam2egBT0kJ9gi(vujlysYaPKyPVbsNbS5WdfNX7dJfYIsqFfgBGi9gCVQbINfWvuKfC6mGnhEO4mEFySqwuc6RW468whHsLc0PVJO59jUM919X1zxDtKMb6vF2aPZa2C4HIZ49HXczrjOVcJnHXwlNWyVbIFfvYcMKmqkjw6BGIvGXbT9ZeQaBDgisVb3RAG4zbCffzbxScmoOTFMqfyRZa9QpBGIvGXbT9ZeQaBDMWyRLtYyVbIFfvYcMKmqKEdUx1arOuPaD67iAEFIRzFDFCD2v3ePzGusS03abI58gSp2egBT0Am2BGusS03anv7EPDMoYSe8zde)kQKfmjzcJTwMCJ9gi(vujlysYar6n4EvdKod3BWo5cpltpJf3Edh)kQKfQZBDZRJqPsb603Tpr7xJL(UM919X1bN6SQoGaRJqPsb603ryjJJvLzvUWEF(dxZ(6(46GtDwAvDayGusS03aT)Zn8AWMWyRLaUXEde)kQKfmjzGi9gCVQbsGgom4p2MDn7R7JRZU6G768wNanC(u6p2MDn7R7JRZU6S0Q68w386eOHdhSuQDEi1MDn7R7JRZU6sEDabwhI1fQK)WHdwk1opKAZo(vujluha15Tovmt8WKe15ToeRdfCmCenVpXbkAGusS03aTpr7xJL(MWyRLWTXEde)kQKfmjzGi9gCVQbsXrRYSiDk31zhY6MuA15ToeRdfCmCenVpXbkwN36uXmXdtsuN36MxNanCyWFSn7A2x3hxND1zvDERtGgoFk9hBZUyjj2hwDERBEDc0WHdwk1opKAZUyjj2hwDabwhI1fQK)WHdwk1opKAZo(vujluha1bGbsjXsFdeHLmowvMv5c795pmHXwlTEJ9gi(vujlysYar6n4Evd086qbhdhrZ7tCGI1beyDekvkqN(oIM3N4A2x3hxND1nrA1bqDERdtLANN2A4XPIzIhMKWaPKyPVbAa2PNPJmlbF2egBTknJ9gi(vujlysYar6n4Evd086qbhdhrZ7tCGI1beyDekvkqN(oIM3N4A2x3hxND1nrA1bqDERtfZepmjHbsjXsFd0G2eoth5xdWMnHXwRS0yVbIFfvYcMKmqKEdUx1aHcogoCOTK2cUM919X1bN6MOoV1HyDyQu780wdpovmt8WKegiLel9nqe9jSmJcoggiuWXi)QpBGWH2sAlycJTwzLXEde)kQKfmjzGi9gCVQbAEDOGJHdhAlPTGdhkjrDWPUjQdiW6qbhdho0wsBbxZ(6(46SdzDWDDauN36WISuMdTHXbUo7qwh8AVkQKD4ro0ggh468w386cTHXHlwFoh0SWY1zrDwwha1bx1HfzPmhAdJdCD2vhHIJ6s26SYzngiLel9nq4q7HkLMWyRvtyS3aXVIkzbtsgisVb3RAGMxxOs(dho0wsBbh)kQKfQZBDZRdfCmC4qBjTfC4qjjQdo1nrDabwhk4y4WH2sAl4A2x3hxNDiRZAQZBDOGJHtBI(ljlckXA7WHssuhCQdURdG6acSoeRluj)HdhAlPTGJFfvYc15TU51HcogoTj6VKSiOeRTdhkjrDWPo4UoGaRdfCmCenVpXbkwha1bqDERdlYszo0gghyho0EOszDWPo41Evuj7WJCOnmoW15TouWXWjbFTZSViDk3(8hoCOKe1zrDOGJHdtLANzFr6uU95pC4qjjQdo1nP68whk4y4WuP2z2xKoLBF(dhousI6GtDtuN36qbhdNe81oZ(I0PC7ZF4WHssuhCQBI68w386qSoDgU3GD4OznX(WY4qBSJFfvYc1beyDiwhk4y4iAEFIduSoGaRdX6eBgEho0gd2W46aOoGaRl0gghUy95CqZclxhCqwhBDmbm4CS(CDWvDkoAvMfPt5UUKTUjLwDabwhI1HPsTZtBn84uXmXdtsyGusS03aHdTXGnm2egBTAsg7nq8ROswWKKbsjXsFdeg8hBZgisVb3RAGAE0m2JIk568w386uXmXdtsuN36gskTRBEDH2W4WfRpNdAwy56s26MxNv1bx1HfzPm7rXbxha1bqDWvDyrwkZH2W4axNDiRBs1zrDyrwkZH2W4axN36MxhwKLYCOnmoW1zxDwwNf1fQK)Wft3p7tPp2XVIkzH6acSobA48P0FSn7ILKyFy1bqDERBEDiwNod3BWoC0SMyFyzCOn2XVIkzH6acSoeRdfCmCenVpXbkwhqG1HyDIndVdd(JT56aOoamqK0jsohAdJdSXwlnHXwRSgJ9gi(vujlysYaPKyPVbYNs)X2SbI0BW9QgOMhnJ9OOsUoV1nVovmt8WKe15TUHKs76MxxOnmoCX6Z5GMfwUUKTU51zvDWvDyrwkZEuCW1bqDauhCvhwKLYCOnmoW1zhY6sEDERBEDiwNod3BWoC0SMyFyzCOn2XVIkzH6acSoeRdfCmCenVpXbkwhqG1HyDIndVZNs)X2CDauhagis6ejNdTHXb2yRLMWyRvj3yVbIFfvYcMKmqkjw6BGWblLANhsTzdeP3G7vnqnpAg7rrLCDERBEDQyM4HjjQZBDdjL21nVUqByC4I1NZbnlSCDjBDZRZQ6GR6WISuM9O4GRdG6aOo7qwxYRZBDZRdX60z4Ed2HJM1e7dlJdTXo(vujluhqG1HyDOGJHJO59joqX6acSoeRtSz4D4GLsTZdP2CDauhagis6ejNdTHXb2yRLMWyRvaUXEde)kQKfmjzGi9gCVQbsfZepmjHbsjXsFd0ZtZ(u6BcJTwb3g7nq8ROswWKKbI0BW9Qgivmt8WKegiLel9nqEu5i7tPVjm2AL1BS3aXVIkzbtsgisVb3RAGuXmXdtsyGusS03anaLYSpL(MWy7ePzS3aXVIkzbtsgisVb3RAGqbhdhMk1oZ(I0PC7ZF4WHssuhCQBI68w386uXmXdtsuhqG1Hcogoj4RDM9fPt52N)WHdLKOoK1nrDauN36Mx386qbhd3uT7L2z6iZsWNDGI1beyDOGJHtc(ANzFr6uU95pCGI1beyDyrwkZH2W4axNDiRZQ68whI1HcogomvQDM9fPt52N)Wbkwha15TU51HyD6mCVb7WrZAI9HLXH2yh)kQKfQdiW6qSouWXWr08(ehOyDabw386qSoXMH3jbFTZ4O3eCDERdX6cvYF42NO9RXsFh)kQKfQdiW6eBgEhMk1opT1WtDauha1beyD6mCVb7WrZAI9HLXH2yh)kQKfQZBDOGJHJO59joqX68wNyZW7WuP25PTgEQdadKsIL(gij4RDgh9MGnHX2jS0yVbIFfvYcMKmqKEdUx1aPZW9gSdhnRj2hwghAJDT(jQdo1nrDabwhI1HcogoIM3N4afRdiW6qSoXMH3HPsTZtBn8yGusS03aHPsTZtBn8ycJTtyLXEdKsIL(gim4p2Mnq8ROswWKKjmHbsSzc1hvdJ9gBT0yVbIFfvYcMKmHXwRm2BG4xrLSGjjtySDcJ9gi(vujlysYegBNKXEde)kQKfmjzGOIgimhgiLel9nqWR9QOs2abVkbzd0KQZI60z4Ed2Pnr)LKfbLyTD8ROswOolQluj)HdhAlPTGJFfvYc1zrDZRtNH7nyhoAwtSpSmo0g7A9tuND1zvDERtNH7nyN2e9xsweuI12XVIkzH6aOUzxhI1fQK)Wft3p7tPp2XVIkzbde8ANF1Nnq4ro0gghytyS1Am2BGusS03a5tPFI9ZdA7BG4xrLSGjjtySn5g7nq8ROswWKKjm2c4g7nqkjw6BGePXsFde)kQKfmjzcJTWTXEdKsIL(gimvQDEARHhde)kQKfmjzctycde8CJx6BS1Q0S06tBsPzPZYjnbGBGMQ9VpmSbAY7ls7GfQZQ6usS0Vo5IdSRszGeB6yLSbcq1LKk1NW1LmBWvOsbO68eHigWIacW2WdiQJq9raV(Gsnw6tADeiGxFccvkavN1k2RSoRsZM6SknlT(6MDDwc4a20a8kvLcq1nRE0hgJbSvkav3SRZAfeyH6GOsTRljw9Dvkav3SRBw9OpmwOUqByCK3rDefZ46cADK0jsohAdJdSRsbO6MDDwRaGbioyH6WJCOnmoW1bV2RIk56g0UovqG(1Ht)d16Cvkav3SRdA9fL7i96S2z4EdUUO1nQtsPjafX1nxG(twuhiMRd8FMWyS2Pxh8AVkQKRdN(hQ1bGRsbO6MDDtoSpfEwOUKHfEwMEDqIBVrDe6lSXs)6g0UUzLLmowvwN1kxyVp)bGzDPtbNmPSopk8CDBuhTRlDkyDtP)Kf1H3NW1n5)NB41GRBX15zH5H76e7L2BKURsvPauDtUwhtadwOouEqBUoc1hvJ6qzy7JD1zTeclg46E6pBpA7paL1PKyPpUo6lt3vPusS0h7eBMq9r1a5qQ4evkLel9XoXMjuFunSajcdkvOsPKyPp2j2mH6JQHfirqbH5ZFOXs)kvLcq1zTZW9gCDWR9QOsgxPauDkjw6JDIntO(OAybseGx7vrLSnV6Zi1zYySnWRsqgPod3BWoC0SMyFyzCOn216NOsbO6usS0h7eBMq9r1WcKiaV2RIkzBE1NrQZKvrBGxLGmsDgU3GDAt0FjzrqjwBxRFIkvLcq1bfApuPSo4Rdk0gd2W46cTHXrDeWGogvkLel9XoXMjuFunSajcWR9QOs2Mx9zK4ro0gghyBOIiXCyd8QeKrojl0z4Ed2Pnr)LKfbLyTD8ROswWIqL8hoCOTK2co(vujlyXCDgU3GD4OznX(WY4qBSR1pHDw5vNH7nyN2e9xsweuI12XVIkzbaMnIHk5pCX09Z(u6JD8ROswOsPKyPp2j2mH6JQHfirWNs)e7Nh02VsvPauDqVkI9qJ6ADfQdfCmyH6WHg46q5bT56iuFunQdLHTpUo9fQtS5zlsJyFy1T46eOp7Qukjw6JDIntO(OAybseWVkI9qJmo0axPusS0h7eBMq9r1WcKiisJL(vkLel9XoXMjuFunSajcyQu780wdpvQkfGQBY16ycyWc1XWZD61fRpxx4HRtjbTRBX1PWRRurLSRsPKyPpgjMk1oJYQFLsjXsFSfirqKgl9TzhirbhdhrZ7tCn7R7JTl5EvsSWZz(z)LXiTSsPKyPp2cKiisJL(28QpJevJqYzrAS0pth59dwkzsyZoqIcogoIM3N4A2x3hBxYRukjw6JTajcOskvipa70TzhirbhdhrZ7tCGIvkLel9XwGebuUXCNyFy2SdKOGJHJO59joqXkLsIL(ylqIG2e95Cq7M)WMDGefCmCenVpXbkwPusS0hBbseKlmpbodyakaZN)WMDGefCmCenVpXbkwPusS0hBbsegBZOskvWMDGefCmCenVpXbkwPusS0hBbse0NW4OvzMOsPn7ajk4y4iAEFIduSsvPauDZAYexPusS0hBbseaXCEd23Mx9zKOQKhBZz0wFIhB2bsEwaxrrwWzP1y9jFI08sOuPaD67iAEFIRzFDFSDtKwLsjXsFSfiraeZ5nyFBE1Nrk0SkKHjvHvdAJZOQam2MDGKNfWvuKfCwMClT(0SYlHsLc0PVJO59jUM919X2nrAvkLel9XwGebqmN3G9T5vFgPodyZHhkoJ3hglKfLG(km2MDGKNfWvuKfCwMClNaWbCVekvkqN(oIM3N4A2x3hB3ePvPusS0hBbseaXCEd23Mx9zKXkW4G2(zcvGToB2bsEwaxrrwWzzYTgRbWtELsjXsFSfiraeZ5nyFSn7ajHsLc0PVJO59jUM919X2nrAvkLel9XwGeHPA3lTZ0rMLGpxPusS0hBbse2)5gEnyB2bsDgU3GDYfEwMEglU9go(vujl4DoHsLc0PVBFI2Vgl9Dn7R7JHJvabsOuPaD67iSKXXQYSkxyVp)HRzFDFmCS0kaQukjw6JTajc7t0(1yPVn7aPanCyWFSn7A2x3hBhC7vGgoFk9hBZUM919X2zPvENlqdhoyPu78qQn7A2x3hBxYbceXqL8hoCWsP25HuB2XVIkzba8QIzIhMKWlIOGJHJO59joqXkfGQlzs)jlQtjbOkLPxhXdtsu3G21LmSWZY0RdsC7nQZd3mGzDPtbNmPSopk8CDBuhTRlDkyDtP)KfUkLsIL(ylqIaHLmowvMv5c795pSzhivC0QmlsNYTDiNuAErefCmCenVpXbk6vfZepmjH35c0WHb)X2SRzFDFSDw5vGgoFk9hBZUyjj2hM35c0WHdwk1opKAZUyjj2hgqGigQK)WHdwk1opKAZo(vujlaaavkLel9XwGeHbyNEMoYSe8zB2bY5OGJHJO59joqrGajuQuGo9DenVpX1SVUp2UjsdaVyQu780wdpovmt8WKevkLel9XwGeHbTjCMoYVgGnBZoqohfCmCenVpXbkceiHsLc0PVJO59jUM919X2nrAa4vfZepmjrLQsbO6Ge5xGBCLsjXsFSfirGOpHLzuWXWMx9zK4qBjTfSzhirbhdho0wsBbxZ(6(y4mHxeXuP25PTgECQyM4HjjQukjw6JTajc4q7HkL2SdKZrbhdho0wsBbhousc4mbqGOGJHdhAlPTGRzFDFSDiHBa8IfzPmhAdJdSDiHx7vrLSdpYH2W4a7DEOnmoCX6Z5GMfw2clbaUWISuMdTHXb2ocfhjRvoRPsPKyPp2cKiGdTXGnm2MDGCEOs(dho0wsBbh)kQKf8ohfCmC4qBjTfC4qjjGZeabIcogoCOTK2cUM919X2H0A8IcogoTj6VKSiOeRTdhkjbCGBaaceXqL8hoCOTK2co(vujl4Dok4y40MO)sYIGsS2oCOKeWbUbcefCmCenVpXbkcaaEXISuMdTHXb2HdThQuch41Evuj7WJCOnmoWErbhdNe81oZ(I0PC7ZF4WHssybk4y4WuP2z2xKoLBF(dhousc4mjVOGJHdtLANzFr6uU95pC4qjjGZeErbhdNe81oZ(I0PC7ZF4WHssaNj8ohrDgU3GD4OznX(WY4qBSJFfvYcabIik4y4iAEFIdueiqefBgEho0gd2Wyaacm0gghUy95CqZcldhKS1XeWGZX6ZWLIJwLzr6uUt2jLgqGiIPsTZtBn84uXmXdtsuPQuaQUKj1ECLsjXsFSfirad(JTzBiPtKCo0gghyKwAZoq28OzShfvYENRIzIhMKW7qsP98qByC4I1NZbnlSCYo3k4clYsz2JIdgaaGlSilL5qByCGTd5KSalYszo0gghyVZXISuMdTHXb2olTiuj)HlMUF2NsFSJFfvYcabkqdNpL(JTzxSKe7ddaVZruNH7nyhoAwtSpSmo0g74xrLSaqGiIcogoIM3N4afbcerXMH3Hb)X2maauPusS0hBbse8P0FSnBdjDIKZH2W4aJ0sB2bYMhnJ9OOs27Cvmt8WKeEhskTNhAdJdxS(CoOzHLt25wbxyrwkZEuCWaaaCHfzPmhAdJdSDitU35iQZW9gSdhnRj2hwghAJD8ROswaiqerbhdhrZ7tCGIabIOyZW78P0FSndaavkLel9XwGebCWsP25HuB2gs6ejNdTHXbgPL2SdKnpAg7rrLS35QyM4Hjj8oKuApp0gghUy95CqZclNSZTcUWISuM9O4Gbaa7qMCVZruNH7nyhoAwtSpSmo0g74xrLSaqGiIcogoIM3N4afbcerXMH3Hdwk1opKAZaaqLQsbO6sgZp3AqBCLsjXsFSfir45PzFk9TzhivXmXdtsuPusS0hBbse8OYr2NsFB2bsvmt8WKevkLel9XwGeHbOuM9P03MDGufZepmjrLsjXsFSfirqc(ANXrVjyB2bsuWXWHPsTZSViDk3(8hoCOKeWzcVZvXmXdtsaeik4y4KGV2z2xKoLBF(dhouscKtaG35Zrbhd3uT7L2z6iZsWNDGIabIcogoj4RDM9fPt52N)WbkceiwKLYCOnmoW2H0kViIcogomvQDM9fPt52N)WbkcG35iQZW9gSdhnRj2hwghAJD8ROswaiqerbhdhrZ7tCGIabohrXMH3jbFTZ4O3eSxedvYF42NO9RXsFh)kQKfacuSz4DyQu780wdpaaaqG6mCVb7WrZAI9HLXH2yh)kQKf8IcogoIM3N4af9k2m8omvQDEARHhaQukjw6JTajcyQu780wdp2SdK6mCVb7WrZAI9HLXH2yxRFc4mbqGiIcogoIM3N4afbcerXMH3HPsTZtBn8uPauDjJuPm80G1nODD(u4zF(JkLsIL(ylqIag8hBZgiSitm2AzAwzctyma]] )


end