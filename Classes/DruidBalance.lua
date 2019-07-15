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

    spec:RegisterHook( "pregain", function( amt, resource, overcap, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt > 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )

    spec:RegisterHook( "prespend", function( amt, resource, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt < 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
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

            spend = -25,
            spendType = "rage",

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
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

            copy = { "incarnation_chosen_of_elune", "Incarnation" },
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

            spend = -10,
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

                if talent.twin_moons.enabled and active_enemies > 1 then
                    active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
                end
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

            startsCombat = false,
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

            spend = -3,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            

            readyTime = function()
                return mana[ "time_to_" .. ( 0.12 * mana.max ) ]
            end,

            handler = function ()
                spend( 0.12 * mana.max, "mana" ) -- I want to see AP in mouseovers.
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
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


    spec:RegisterPack( "Balance", 20190715.0815, [[dGeg5aqivv9iQk5ssHQnHs(KuO0OKkDkPkRcQsEffPzHI6wsfXUO0VGQAysPCmuKLjf8mPcttQOUgvLABue5BsfPXbvHZjfI1rru9oOksnpkc3dQSpkkheQszHuv5HueLjcvr1fHQizJsHI8rPqrDsPqHvkLmtOkkTtkQwkuffpfKPsvXEr1FfmyGdtAXu4XiMmOUmXMf6ZOWOLIoTIvdvr8AuQztLBdLDRYVHmCQYXHQuTCjphPPl66QY2LQ67QQmEPq68uv16Ls18vv2VsZzI7dhcwtHBEdTXuJ0wNYKVTTHhm1qBnchk93t4qEkHTYq4qNIjCi)uNEeHd5P(7qkm3hoef9kIWHAMPh1KJp(mMS5ZWsqy4thSNtZbDKsJj(0bJGphY4nUSX44gCiynfU5n0gtnsBDkt(22gEWudT1PCi9LnrfhcAWmzCOMdmSCCdoeSqjCiFTa)uNEezb451BG3w(AbnZ0JAYXhFgt28zyjim8Pd2ZP5GosPXeF6GrWFB5Rf0658Fbm5BMxqdTXuJSGozbTHhMCM892AB5RfyYAQhdHAY3w(AbDYcWBWWc8cGqoTwGFIIz3w(AbDYcmzn1JHaVGulgsgM4cikvOlirlG4pXjHulgssTBlFTGozbqdMNBI(Va8w7snPSGS0jxGdHy)8OlOlm6AS5cEuzbV7eIqPA5)c6R1Ogozbu)VuB0E2TLVwqNSa8mcgQVaVa8StFX5)cG8MAYfqqh8Kd6wqevlWKjoHMJ6waEZnmom5s80lWF0RX6ClOP2xwWKlavlWF0Bb)qxJnxaDoISGgJ7KQVMYcg6cAomAk1c8Qbvt6VLd5gAs5(WHGLO(Cj3hU5mX9HdPKCqhhIICAfmefJdjNA4eyUF8KBEdCF4qYPgobM7hhIutk1OCiJxmAjAyoITemDo6cmBbMehsj5GooKhkh0XtU5DW9HdjNA4eyUFCisnPuJYHmEXOLOH5i2Nhhsj5GooKHdHGdXx5pp5M3zUpCi5udNaZ9JdrQjLAuoKXlgTenmhX(84qkjh0XHmKIkf75yWtU5(M7dhso1WjWC)4qKAsPgLdz8IrlrdZrSppoKsYbDCiTi6jHevLCjp5MBsCF4qYPgobM7hhIutk1OCiJxmAjAyoI95XHusoOJd5ggntAap5bZatUKNCZ7uUpCi5udNaZ9JdrQjLAuoKXlgTenmhX(84qkjh0XHItjgoecMNCZXdUpCi5udNaZ9JdrQjLAuoKXlgTenmhX(84qkjh0XH0Ji0SuxGOohp5M3iCF4qYPgobM7hhsj5GooK2oTPwknerxgqXGh6NuCisnPuJYHe8(B88eyR2oTPwknerxgqXGh6NulG1cGrPfdHU4uInhc75ySawlagLw67Itj2CiSNJXcyTGUl4)cs1jxAPP4CAfIoTeRCQHtGxW33cGrPLMIZPvi60sS5qyphJf0JdDkMWH02Pn1sPHi6Yakg8q)KINCZzQnUpCi5udNaZ9JdrQjLAuou3f8FbP6KlT0ulhQGTYPgobEbFFlW4fJwAQLdvW2N3c6TawlagLwme6Itj2CiSNJXcyTayuAPVloLyZHWEoglG1c6UG)livNCPLMIZPvi60sSYPgobEbFFlagLwAkoNwHOtlXMdH9CmwqpoKsYbDCigpTGh9cOyqBxku2KNCZzIjUpCi5udNaZ9JdPKCqhhkhyHMOclqqWsJYHi1KsnkhsW7VXZtGT5al0evybccwAuo0PychkhyHMOclqqWsJYtU5m1a3hoKCQHtG5(XHusoOJd5HiSLKoTlWbccZ7LAoOlal9hIWHi1KsnkhsW7VXZtGTEicBjPt7cCGGW8EPMd6cWs)HilG1cGrPfdHU4uInhc75ySawlagLw67Itj2CiSNJXcyTGUl4)cs1jxAPP4CAfIoTeRCQHtGxW33cGrPLMIZPvi60sS5qyphJf0JdDkMWH8qe2ssN2f4abH59snh0fGL(dr4j3CM6G7dhso1WjWC)4qkjh0XHOnN(sf6lhcluIBiCisnPuJYHe8(B88eylT50xQqF5qyHsCdzbSwabHCWOFNLOH5i2sW05OlWSf0rBlG1c(VaJxmAjAyoI95XHoft4q0MtFPc9LdHfkXneEYnNPoZ9HdjNA4eyUFCisnPuJYHiiKdg97SenmhXwcMohDbMTGoAJdPKCqhh6rLWKcgLNCZzY3CF4qYPgobM7hhIutk1OCicc5Gr)olrdZrSLGPZrxGzlOJ24qkjh0XHmCieCafdztjiNG5pp5MZKjX9HdjNA4eyUFCisnPuJYHGrPL(U4uITemDo6cmBbm12cyTayuAXqOloLylbtNJUaZwatTTawlO7c(VGuDYLwAkoNwHOtlXkNA4e4f89TayuAPP4CAfIoTeBjy6C0fy2cyQTf0BbSwW)fy8IrlrdZrSpVfWAbDxGsZsDbp0pPwGjwqd(EbFFlGGqoy0VZs0WCeBjy6C0fy2c6OTf0JdPKCqhhctWqL)bum4EKboaxIIr5j3CM6uUpCiLKd64qEVAI(phJGHtPjhso1WjWC)4j3CMWdUpCiLKd64q1455KWCbQNseoKCQHtG5(XtU5m1iCF4qkjh0XHiOJixwAkWHOtXeoKCQHtG5(XtU5n0g3hoKCQHtG5(XHi1KsnkhY4fJ2siSDcLgIOIi2N3c((wqoyYcmXc8nhsj5Goou2ucVZa9o4qeveHNCZBGjUpCiLKd64q)qLdUVmxOek60JiCi5udNaZ9JNCZBObUpCiLKd64qre5rf4G2UutkbdrX4qYPgobM7hp5M3qhCF4qkjh0XHy80cE0lGIbTDPqztoKCQHtG5(XtU5n0zUpCiLKd64qztuDuoKCQHtG5(XtU5n4BUpCiLKd64q)0QgufqXG4ENWHKtnCcm3pEYnVbtI7dhso1WjWC)4qKAsPgLd9FbgVy0s0WCe7ZBbSwq3fy8IrlMGHk)dOyW9idCaUefJAFEl47BbDxq3fqqihm63zXemu5FafdUhzGdWLOyuBjy6C0fy2cAOTf89TG)lqOu5iIftWqL)bum4EKboaxIIrTykEcQwqVfWAbQxG0uiSxaRfO0SuxWd9tQfygUf052wqVf0BbSwq3fy8IrlMGHk)dOyW9idCaUefJAFEl47BbQxG0uiSxqVfWAbWO0sFxCkXwcMohDbMTa8ybSwamkTyi0fNsSLGPZrxGzlGPgwaRf0DbWO0stX50keDAj2sW05OlWSfysl47Bb)xqQo5slnfNtRq0PLyLtnCc8c6XHusoOJdnhrRtZbD8KBEdDk3hoKCQHtG5(XHi1Ksnkh6)cmEXOLOH5i2N3cyTGUlW4fJwmbdv(hqXG7rg4aCjkg1(8wW33c6UGUlGGqoy0VZIjyOY)akgCpYahGlrXO2sW05OlWSf0qBl47Bb)xGqPYrelMGHk)dOyW9idCaUefJAXu8euTGElG1cuVaPPqyVawlqPzPUGh6NulWmClOZTTGElO3cyTGUlagLw67Itj2sW05OlWSf0WcyTayuAXqOloLyZHWEoglG1c6UayuAPP4CAfIoTeBoe2ZXybFFl4)cs1jxAPP4CAfIoTeRCQHtGxqVf0JdPKCqhhIioHMJ6cQByCyYL8KBEd4b3hoKCQHtG5(XHi1KsnkhQ7cmEXOLOH5i2N3c((wabHCWOFNLOH5i2sW05OlWSf0rBlO3cyTakYPv4xPztR6finfcBoKsYbDCO4R8pGIbX9oHNCZBOr4(WHKtnCcm3poePMuQr5qDxGXlgTenmhX(8wW33ciiKdg97SenmhXwcMohDbMTGoABb9waRfOEbstHWMdPKCqhhkIkIeqXWP5ReEYnVJ24(WHKtnCcm3poePMuQr5qgVy0stTCOc2wcMohDbMybDSawl4)cOiNwHFLMnTQxG0uiS5qkjh0XHi6rexW4fJCiJxmgoft4q0ulhQG5j38oyI7dhso1WjWC)4qKAsPgLd1DbgVy0stTCOc2stLWEbMybDSGVVfy8Irln1YHkyBjy6C0fygUfGhlO3cyTaQN4CHulgssxGz4wqFTg1WjwAmKAXqs6cyTGUli1IHK2CWKqIcWJSatxatlO3cWRfq9eNlKAXqs6cmBbeenxqJVGgS(MdPKCqhhIMAfvNJNCZ7ObUpCi5udNaZ9JdrQjLAuou3fKQtU0stTCOc2kNA4e4fWAbDxGXlgT0ulhQGT0ujSxGjwqhl47BbgVy0stTCOc2wcMohDbMHBb(EbSwGXlgTAr0BibVNJQLLMkH9cmXcWJf0BbFFl4)cs1jxAPPwoubBLtnCc8cyTGUlW4fJwTi6nKG3Zr1YstLWEbMyb4Xc((wGXlgTenmhX(8wqVf0BbSwa1tCUqQfdjPwAQvuDUfyIf0xRrnCILgdPwmKKUawlW4fJw370kiyEOFsHjxAPPsyVatxGXlgTuKtRGG5H(jfMCPLMkH9cmXc68cyTaJxmAPiNwbbZd9tkm5slnvc7fyIf0XcyTaJxmADVtRGG5H(jfMCPLMkH9cmXc6ybSwq3f8FbA7snPyPzjk75yeOPwuBPh7f89TG)lW4fJwIgMJyFEl47Bb)xGxj9T0ul6RyilO3c((wqQfdjT5GjHefGhzbMa3cKgviVuc5GjlaVwGsZsDbp0pPwqJVGo32c((wW)fqroTc)knBAvVaPPqyZHusoOJdrtTOVIHWtU5D0b3hoKCQHtG5(XHi1KsnkhY4fJwIgMJyFElG1cmEXOLOH5i2sW05OlWelGbb2IPn6cyTaTDPMuS0SeL9Cmc0ulQT0J9cyTayuAXqOloLylbtNJUaZwqjy6CuoKsYbDCi67Itj8KBEhDM7dhso1WjWC)4qKAsPgLdz8IrlrdZrSpVfWAbgVy0s0WCeBjy6C0fyIfWGaBX0gDbSwG2UutkwAwIYEogbAQf1w6XMdPKCqhhcdHU4ucp5M3HV5(WHKtnCcm3poKsYbDCi67ItjCisnPuJYHkjwcTPA4KfWAbQxG0uiSxaRfeDiuTGUli1IHK2CWKqIcWJSGgFbDxqdlaVwa1tCUqtLMYc6TGElaVwa1tCUqQfdjPlWmClGiJBbDxq0Hq1c6UGgwqJVaQN4CHulgssxqVfGxlGjRVxqVfy6cAyb41cOEIZfsTyijDbSwq3fq9eNlKAXqs6cmBbmTatxqQo5sB(BUagcDuRCQHtGxW33cGrPfdHU4uInhc75ySGElG1c6UG)lqBxQjflnlrzphJan1IAl9yVGVVf8FbgVy0s0WCe7ZBbFFl4)c8kPVL(U4uYc6TawlO7cmEXOLOH5i2sW05OlWSfucMohDbFFl4)cmEXOLOH5i2N3c6XHi(tCsi1IHKuU5mXtU5DysCF4qYPgobM7hhsj5GooegcDXPeoePMuQr5qLelH2unCYcyTa1lqAke2lG1cIoeQwq3fKAXqsBoysirb4rwqJVGUlOHfGxlG6joxOPstzb9wqVfGxlG6joxi1IHK0fygUfyslG1c6UG)lqBxQjflnlrzphJan1IAl9yVGVVf8FbgVy0s0WCe7ZBbFFl4)c8kPVfdHU4uYc6TawlO7cmEXOLOH5i2sW05OlWSfucMohDbFFl4)cmEXOLOH5i2N3c6XHi(tCsi1IHKuU5mXtU5D0PCF4qYPgobM7hhsj5GooenfNtRq0PLWHi1KsnkhQKyj0MQHtwaRfOEbstHWEbSwq0Hq1c6UGulgsAZbtcjkapYcA8f0DbnSa8AbupX5cnvAklO3c6TaZWTaFVawlO7c(VaTDPMuS0SeL9Cmc0ulQT0J9c((wW)fy8IrlrdZrSpVf89TG)lWRK(wAkoNwHOtlzb94qe)jojKAXqsk3CM4j38oWdUpCi5udNaZ9JdrQjLAuoK6finfcBoKsYbDCOt(fWqOJNCZ7Or4(WHKtnCcm3poePMuQr5qQxG0uiS5qkjh0XHAQUyadHoEYnVZTX9HdjNA4eyUFCisnPuJYHuVaPPqyZHusoOJdfFoxadHoEYnVZmX9HdjNA4eyUFCisnPuJYHmEXOLICAfemp0pPWKlT0ujSxGjwqhlG1c6Ua1lqAke2l47BbgVy06ENwbbZd9tkm5slnvc7fGBbDSGElG1c6UGUlW4fJ2FAvdQcOyqCVtSpVf89TaJxmADVtRGG5H(jfMCP95TGVVfq9eNlKAXqs6cmd3cAybSwW)fy8Irlf50kiyEOFsHjxAFElO3cyTGUl4)c02LAsXsZsu2ZXiqtTO2sp2l47Bb)xGXlgTenmhX(8wqVf89TaTDPMuS0SeL9Cmc0ulQT0J9cyTaJxmAjAyoI95TawlWRK(wkYPv4xPzZf0JdPKCqhhY9oTc0Sg2cp5M35g4(WHKtnCcm3poePMuQr5qA7snPyPzjk75yeOPwuBPh7fyIf0Xc((wW)fy8IrlrdZrSpVf89TG)lWRK(wkYPv4xPztoKsYbDCikYPv4xPztEYnVZDW9HdPKCqhhI(U4uchso1WjWC)4jp5qELqqygAY9HBotCF4qYPgobM7hp5M3a3hoKCQHtG5(XtU5DW9HdjNA4eyUF8KBEN5(WHKtnCcm3poeYJdrLKdPKCqhhQVwJA4eouF19eouN5q91kCkMWHOXqQfdjP8KBUV5(WHKtnCcm3poeYJdPWWCiLKd64q91AudNWH6RUNWHyIdrQjLAuoK2UutkwTi6nKG3Zr1YkNA4eyouFTcNIjCiAmKAXqskp5MBsCF4qYPgobM7hhc5XHuyyoKsYbDCO(AnQHt4q9v3t4qmXHi1KsnkhkvNCPLMA5qfSvo1WjWCO(Afoft4q0yi1IHKuEYnVt5(WHKtnCcm3poeYJdPWWCiLKd64q91AudNWH6RUNWHyIdrQjLAuoK2UutkwAwIYEogbAQf1w6XEbMTGgwaRfOTl1KIvlIEdj49CuTSYPgobMd1xRWPychIgdPwmKKYtU54b3hoKCQHtG5(XHqECi6ZGdPKCqhhQVwJA4eouF19eoetCisnPuJYH(VGuDYL283Cbme6Ow5udNaZH6Rv4umHdrJHulgss5j38gH7dhsj5GooegcDSNlerfghso1WjWC)4j3CMAJ7dhsj5GooKhkh0XHKtnCcm3pEYnNjM4(WHusoOJdrroTc)knBYHKtnCcm3pEYtEYH6lfDqh38gAJPgPToTTgXYeEWH(P1nhdkhQXaZdvPaVGgwGsYbDlWn0KA3wCiVcfhNWH81c8tD6rKfGNxVbEB5Rf0mtpQjhF8zmzZNHLGWWNoypNMd6iLgt8Pdgb)TLVwqRNZ)fWKVzEbn0gtnYc6Kf0gEyYzY3BRTLVwGjRPEmeQjFB5Rf0jlaVbdlWlac50Ab(jkMDB5Rf0jlWK1upgc8csTyizyIlGOuHUGeTaI)eNesTyij1UT81c6KfanyEUj6)cWBTl1KYcYsNCboeI9ZJUGUWORXMl4rLf8UticLQL)lOVwJA4Kfq9)sTr7z3w(AbDYcWZiyO(c8cWZo9fN)laYBQjxabDWtoOBbruTatM4eAoQBb4n3W4WKlXtVa)rVgRZTGMAFzbtUauTa)rVf8dDn2Cb05iYcAmUtQ(AklyOlO5WOPulWRgunP)2T12YxlapvJkKxkWlWqIOswabHzO5cmegZrTlaVriIxsxWHUoPPwyXNBbkjh0rxa6C(B3wkjh0rTELqqygAIl6uk7TLsYbDuRxjeeMHMMId)icbVTusoOJA9kHGWm00uC4RpgyYLAoOBBTT81cWBTl1KYc6R1OgoHUT81cusoOJA9kHGWm00uC43xRrnCcZNIj402dukZ9v3tWPTl1KILMLOSNJrGMArTLES3w(Abkjh0rTELqqygAAko87R1OgoH5tXeCA7b1J5(Q7j402LAsXQfrVHe8EoQw2sp2BRTLVwauQvuDUf0FbqPw0xXqwqQfdjxa5LOyCBPKCqh16vcbHzOPP4WVVwJA4eMpftWrJHulgsszUV6EcUoVTusoOJA9kHGWm00uC43xRrnCcZNIj4OXqQfdjPmJ8WPWWm3xDpbhtmprCA7snPy1IO3qcEphvlRCQHtG3wkjh0rTELqqygAAko87R1OgoH5tXeC0yi1IHKuMrE4uyyM7RUNGJjMNiUuDYLwAQLdvWw5udNaVTusoOJA9kHGWm00uC43xRrnCcZNIj4OXqQfdjPmJ8WPWWm3xDpbhtmprCA7snPyPzjk75yeOPwuBPhBZAGL2UutkwTi6nKG3Zr1YkNA4e4TLsYbDuRxjeeMHMMId)(AnQHty(umbhngsTyijLzKho6ZG5(Q7j4yI5jI7FQo5sB(BUagcDuRCQHtG3wkjh0rTELqqygAAko8XqOJ9CHiQW2wBlFTaOt9Onr5ckDGxGXlgf4fqtnPlWqIOswabHzO5cmegZrxGEWlWRKoXdL5CmwWqxam6e72Yxlqj5GoQ1ReccZqttXHp9upAtugOPM0TLsYbDuRxjeeMHMMIdFpuoOBBPKCqh16vcbHzOPP4WNICAf(vA2CBTT81cWt1Oc5Lc8cK(s5)cYbtwq2uwGssuTGHUaTVoo1Wj2TLsYbDuCuKtRGHOyBlLKd6OMIdFpuoOJ5jIZ4fJwIgMJylbtNJAMjTTusoOJAko8nCieCi(k)zEI4mEXOLOH5i2N32sj5GoQP4W3qkQuSNJbZteNXlgTenmhX(82wkjh0rnfh(Ar0tcjQk5sMNioJxmAjAyoI95TTusoOJAko8DdJMjnGN8GzGjxY8eXz8IrlrdZrSpVTLsYbDutXHFCkXWHqWmprCgVy0s0WCe7ZBBPKCqh1uC4RhrOzPUarDoMNioJxmAjAyoI95TT2w(AbMm8C62sj5GoQP4W)rLWKcgZNIj402Pn1sPHi6Yakg8q)KI5jItW7VXZtGTmzsnshm1zwWO0IHqxCkXMdH9CmybJsl9DXPeBoe2ZXGv3)P6KlT0uCoTcrNwIvo1WjWFFWO0stX50keDAj2CiSNJrVTLsYbDutXHpJNwWJEbumOTlfkBY8eX19FQo5sln1YHkyRCQHtG)(mEXOLMA5qfS951JfmkTyi0fNsS5qyphdwWO0sFxCkXMdH9Cmy19FQo5slnfNtRq0PLyLtnCc83hmkT0uCoTcrNwInhc75y0BBPKCqh1uC4)OsysbJ5tXeC5al0evybccwAuMNiobV)gppb2YKj5BF3PM02sj5GoQP4W)rLWKcgZNIj48qe2ssN2f4abH59snh0fGL(dryEI4e8(B88eyltMuN6BF7BwWO0IHqxCkXMdH9CmybJsl9DXPeBoe2ZXGv3)P6KlT0uCoTcrNwIvo1WjWFFWO0stX50keDAj2CiSNJrVTLsYbDutXH)JkHjfmMpftWrBo9Lk0xoewOe3qyEI4e8(B88eyltMeE0iT5BweeYbJ(DwIgMJylbtNJAwhTX6VXlgTenmhX(82wkjh0rnfh(pQeMuWOmprCeeYbJ(DwIgMJylbtNJAwhTTTusoOJAko8nCieCafdztjiNG5pZtehbHCWOFNLOH5i2sW05OM1rBBlLKd6OMIdFmbdv(hqXG7rg4aCjkgL5jIdgLw67Itj2sW05OMXuBSGrPfdHU4uITemDoQzm1gRU)t1jxAPP4CAfIoTeRCQHtG)(GrPLMIZPvi60sSLGPZrnJP26X6VXlgTenmhX(8y1vPzPUGh6NuMObF)9rqihm63zjAyoITemDoQzD0wVTLsYbDutXHV3RMO)ZXiy4uAUTusoOJAko8RXZZjH5cupLiBlLKd6OMIdFc6iYLLMcCi6umzBPKCqh1uC4NnLW7mqVdoerfryEI4mEXOTecBNqPHiQiI9599LdMycFVTusoOJAko8)HkhCFzUqju0Phr2wkjh0rnfh(re5rf4G2UutkbdrX2wkjh0rnfh(mEAbp6fqXG2UuOS52sj5GoQP4WpBIQJUTusoOJAko8)PvnOkGIbX9ozB5RfOKCqh1uC4p3jvFnfMNioTDPMuSUPV48pq9MAsRCQHtGz1LGqoy0VZohrRtZbD2sW05OMOHVpcc5Gr)olrCcnh1fu3W4WKlTLGPZrnbtn0BBPKCqh1uC4phrRtZbDmprC)nEXOLOH5i2NhRUgVy0IjyOY)akgCpYahGlrXO2N33x3UeeYbJ(Dwmbdv(hqXG7rg4aCjkg1wcMoh1SgA777VqPYrelMGHk)dOyW9idCaUefJAXu8eu1JL6finfcBwknl1f8q)KYmCDUTE9y114fJwmbdv(hqXG7rg4aCjkg1(8((uVaPPqy3JfmkT03fNsSLGPZrndpybJslgcDXPeBjy6CuZyQbwDHrPLMIZPvi60sSLGPZrnZK(((NQtU0stX50keDAjw5udNa3BBPKCqh1uC4teNqZrDb1nmom5sMNiU)gVy0s0WCe7ZJvxJxmAXemu5FafdUhzGdWLOyu7Z77RBxcc5Gr)olMGHk)dOyW9idCaUefJAlbtNJAwdT999xOu5iIftWqL)bum4EKboaxIIrTykEcQ6Xs9cKMcHnlLML6cEOFszgUo3wVES6cJsl9DXPeBjy6CuZAGfmkTyi0fNsS5qyphdwDHrPLMIZPvi60sS5qyphJVV)P6KlT0uCoTcrNwIvo1WjW96TTusoOJAko8JVY)akge37eMNiUUgVy0s0WCe7Z77JGqoy0VZs0WCeBjy6CuZ6OTESOiNwHFLMnTQxG0uiS3wkjh0rnfh(rurKakgonFLW8eX114fJwIgMJyFEFFeeYbJ(DwIgMJylbtNJAwhT1JL6finfc7T12YxlaYtoyPOBlLKd6OMIdFIEeXfmEXiZNIj4OPwoubZ8eXz8Irln1YHkyBjy6Cut0bR)uKtRWVsZMw1lqAke2BlLKd6OMIdFAQvuDoMNiUUgVy0stTCOc2stLW2eD89z8Irln1YHkyBjy6CuZWHh9yr9eNlKAXqsQz46R1OgoXsJHulgssz1n1IHK2CWKqIcWJykt9WlQN4CHulgssnJGOzJ3G13BlLKd6OMIdFAQf9vmeMNiUUP6KlT0ulhQGTYPgobMvxJxmAPPwoubBPPsyBIo((mEXOLMA5qfSTemDoQz48nlJxmA1IO3qcEphvllnvcBtGh9(((NQtU0stTCOc2kNA4eywDnEXOvlIEdj49CuTS0ujSnbE89z8IrlrdZrSpVE9yr9eNlKAXqsQLMAfvNZe91AudNyPXqQfdjPSmEXO19oTccMh6NuyYLwAQe2MA8Irlf50kiyEOFsHjxAPPsyBIoZY4fJwkYPvqW8q)KctU0stLW2eDWY4fJw370kiyEOFsHjxAPPsyBIoy19V2UutkwAwIYEogbAQf1w6X(77VXlgTenmhX(8(((7vsFln1I(kgsVVVulgsAZbtcjkapIjWjnQqEPeYbtWlLML6cEOFs14DUTVV)uKtRWVsZMw1lqAke2BlLKd6OMIdF67ItjmprCgVy0s0WCe7ZJLXlgTenmhXwcMoh1emiWwmTrzPTl1KILMLOSNJrGMArTLESzbJslgcDXPeBjy6CuZkbtNJUTusoOJAko8XqOloLW8eXz8IrlrdZrSppwgVy0s0WCeBjy6CutWGaBX0gLL2UutkwAwIYEogbAQf1w6XEBTT81cWZr(q3wkjh0rnfh(03fNsyM4pXjHulgssXXeZtexjXsOnvdNWs9cKMcHnROdHQUPwmK0MdMesuaEKgVBd4f1tCUqtLMsVE4f1tCUqQfdjPMHJiJRB0Hqv3gACQN4CHulgss7Hxmz9DptBaVOEIZfsTyijLvxQN4CHulgssnJjtt1jxAZFZfWqOJALtnCc83hmkTyi0fNsS5qyphJES6(xBxQjflnlrzphJan1IAl9y)9934fJwIgMJyFEFF)9kPVL(U4uspwDnEXOLOH5i2sW05OMvcMoh977VXlgTenmhX(86TTusoOJAko8XqOloLWmXFItcPwmKKIJjMNiUsILqBQgoHL6finfcBwrhcvDtTyiPnhmjKOa8inE3gWlQN4CHMknLE9WlQN4CHulgssndNjXQ7FTDPMuS0SeL9Cmc0ulQT0J933FJxmAjAyoI959993RK(wme6Itj9y114fJwIgMJylbtNJAwjy6C0VV)gVy0s0WCe7ZR32sj5GoQP4WNMIZPvi60syM4pXjHulgssXXeZtexjXsOnvdNWs9cKMcHnROdHQUPwmK0MdMesuaEKgVBd4f1tCUqtLMsVEMHZ3S6(xBxQjflnlrzphJan1IAl9y)9934fJwIgMJyFEFF)9kPVLMIZPvi60s6TT2w(AbnMLtknrfDBPKCqh1uC4FYVagcDmprCQxG0uiS3wkjh0rnfh(nvxmGHqhZteN6finfc7TLsYbDutXHF85Cbme6yEI4uVaPPqyVTusoOJAko8DVtRanRHTW8eXz8Irlf50kiyEOFsHjxAPPsyBIoy1v9cKMcH93NXlgTU3PvqW8q)KctU0stLWgxh9y1TRXlgT)0QgufqXG4ENyFEFFgVy06ENwbbZd9tkm5s7Z77J6joxi1IHKuZW1aR)gVy0sroTccMh6NuyYL2NxpwD)RTl1KILMLOSNJrGMArTLES)((B8IrlrdZrSpVEFFA7snPyPzjk75yeOPwuBPhBwgVy0s0WCe7ZJLxj9TuKtRWVsZM92wkjh0rnfh(uKtRWVsZMmprCA7snPyPzjk75yeOPwuBPhBt0X33FJxmAjAyoI959993RK(wkYPv4xPzZT12YxlOXK6CzZ6TGiQwagQVGjxUTusoOJAko8PVloLWHOEcHBotT1ap5jNd]] )


end