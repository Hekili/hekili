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


    spec:RegisterPack( "Balance", 20190629.0059, [[dG0p2aqiuPEeLOUKufSjkLpjvHmkPItjvAvGk5vuOMffYTesXUOQFbQAyuQCmkWYOK6zcjttQsDnHuTnPk6BOcPXrjsNtQswNqk5DGkvmpub3ds2hQOdcQuwiLKhIkunrqLQUOufkBuiLkFuiLQoPqkLvkuntqLkTtkOLkvHQNQQMkLWEr5VcgmWHjTyu1JrmzqUmXMLYNHuJwOCALwnQq51cXSPYTHy3Q8BOgofDCuHy5sEostx01vLTJk57svnEkrCEkvTEqfZhu2VIzgWSG9H0uygATDg0l76P19YBNDrVxr1l2pT3uyFtLerrlS)Pic7BL60JiSVPAVdRqmlyFk(veH9JLPjnAbp8O3m2J3tWiWtxKNtZfFKsBj80fHap7Z)wxgTDmE2hstHzO12zqVSRNw3lVD2f9EBNbSV(Yy4I9)lchN9JTqqYX4zFiHsyFlpaRuNEezaW91BHM4wEaXY0KgTGhE0Bg7X7jye4PlYZP5IpsPTeE6IqGFIB5be)DYaSUxgnaRTZGEnGOza2zx0kklDIpXT8a44X0dTqJwtClpGOzaWniibAaFStRbyLOi(jULhq0maoEm9qlqdi1cTKHTnaIsf6as8ai2tCsi1cTKu)e3YdiAgaCdIJ9OPanaAlKAHws6a4sRv5DYaA4Aakee(ga1(lvlXpXT8aIMb8xet32SFaWn4i1MYaYs3CaomoYZKoGoq4RhLd4rLb8UticLQL9dGlTwL3jdGA)LQL01pXT8aIMb0JliyUeOba3D5sC2pGV5wBoac(G2CX3aA4AaCCXj0Cv3aGBUf9Hixc3za2JF9iNBaXuUKbS5aW1aSh)gqF81JYbq3JidiA7oP4stzalDaXw0XKAaM1IRnT3Z(ULMuMfSpK00NlzwWm0aMfSVsYfFSpf70kWlkc7lNY7eiMvSKzO1mlyF5uENaXSI9j1MsTk7Z)Anprd7r8LGO7rhaNdONSVsYfFSVjox8XsMHrXSG9Lt5DceZk2NuBk1QSp)R18enShX)mzFLKl(yFEhgdfAVYEwYmS3mlyF5uENaXSI9j1MsTk7Z)Anprd7r8pt2xj5Ip2NxkQur2dnlzggDMfSVCkVtGywX(KAtPwL95FTMNOH9i(Nj7RKCXh7RfrpjK4QKlzjZWEYSG9Lt5DceZk2NuBk1QSp)R18enShX)mzFLKl(yF3IowsdCSheAe5swYmKJYSG9Lt5DceZk2NuBk1QSp)R18enShX)mzFLKl(y)2wcVdJHyjZqlLzb7lNY7eiMvSpP2uQvzF(xR5jAypI)zY(kjx8X(6reAwQlquNJLmd7fZc2xoL3jqmRyFsTPuRY(ch5TMMcKNxDsBljWx6rInaBdGGXoiC)Zt0WEeFji6E0bW5aIYo2)ueH95vN02sc8LEKySVsYfFSpV6K2wsGV0JeJLmdnWoMfSVCkVtGywX(KAtPwL9foYBnnfipujkuaTtHwnXfnWRqOLbyBaem2bH7FEIg2J4lbr3Joaohqu2X(NIiSpujkuaTtHwnXfnWRqOf2xj5Ip2hQefkG2PqRM4Ig4vi0clzgAGbmlyF5uENaXSI9j1MsTk7lCK3AAkqEfoVsYyyAGUhAbky6EikAza2gabJDq4(NNOH9i(sq09OdGZbeLDS)Pic7RW5vsgdtd09qlqbt3drrlSVsYfFSVcNxjzmmnq3dTafmDpefTWsMHgynZc2xoL3jqmRyFsTPuRY(ch5TMMcKpxiHM4cjqWqILW(NIiSFUqcnXfsGGHelH9vsU4J9ZfsOjUqcemKyjSKzObrXSG9Lt5DceZk2NuBk1QSpbJDq4(NNOH9i(sq09OdGZbeLDSVsYfFS)JkHnfeklzgAqVzwW(YP8obIzf7tQnLAv2NGXoiC)Zt0WEeFji6E0bW5aIYo2xj5Ip2N3HXqbClKXKGCcI9SKzObrNzb7lNY7eiMvSpP2uQvzFiC6PVRTL4lbr3JoaohGb2naBdacNEem(ABj(sq09OdGZbyGDdW2a6maUhqQo5spnfNtRqZPL4Lt5Dc0aGbBaq40ttX50k0CAj(sq09OdGZbyGDdO7aSnaUha)R18enShX)mhGTb0zaknl1fmX9LAaCyawh9bad2aiySdc3)8enShXxcIUhDaCoGOSBaDzFLKl(yFebbx2hWTG7rwOaujkcLLmdnONmlyFLKl(yFZxTn73dDG3P0K9Lt5DceZkwYm0aokZc2xj5Ip2VwttNe2lqnvIW(YP8obIzflzgAGLYSG9vsU4J9j4JixwAkqHMtre2xoL3jqmRyjZqd6fZc2xoL3jqmRyFsTPuRY(8VwZxcjItO0qdxeX)mhamydixezaCyarN9vsU4J9Zys4D843bfA4IiSKzO12XSG9vsU4J97JlhexYEHsO4tpIW(YP8obIzflzgATbmlyFLKl(y)gM8OcuqHJuBkbErryF5uENaXSILmdT2AMfSVsYfFSp6NwqREbClOWrkCgJ9Lt5DceZkwYm06OywW(kjx8X(zmCDu2xoL3jqmRyjZqR7nZc2xj5Ip2VVw1IRaUfe37e2xoL3jqmRyjZqRJoZc2xoL3jqmRyFsTPuRY(Cpa(xR5jAypI)zoaBdOZa4FTMhrqWL9bCl4EKfkavIIq9pZbad2a6mGodGGXoiC)ZJii4Y(aUfCpYcfGkrrO(sq09OdGZbyTDdagSbW9aekvoI4reeCzFa3cUhzHcqLOiupIYXW1a6oaBdqndKycjYaSnaLML6cM4(snaornGEB3a6oGUdW2a6ma(xR5reeCzFa3cUhzHcqLOiu)ZCaWGna1mqIjKidO7aSnaiC6PVRTL4lbr3JoaohGLoaBdacNEem(ABj(sq09OdGZbyG1dW2a6maiC6PP4CAfAoTeFji6E0bW5a65aGbBaCpGuDYLEAkoNwHMtlXlNY7eOb0L9vsU4J93JO1P5IpwYm06EYSG9Lt5DceZk2NuBk1QSp3dG)1AEIg2J4FMdW2a6ma(xR5reeCzFa3cUhzHcqLOiu)ZCaWGnGodOZaiySdc3)8iccUSpGBb3JSqbOsueQVeeDp6a4CawB3aGbBaCpaHsLJiEebbx2hWTG7rwOaujkc1JOCmCnGUdW2auZajMqImaBdqPzPUGjUVudGtudO32nGUdO7aSnGodG7bOWrQnfVB5sC2hOMBTPxoL3jqdagSbW)AnVB5sC2hOMBTP)zoGUdW2a6maiC6PVRTL4lbr3JoaohG1dW2aGWPhbJV2wIpxsK9qpaBdOZaGWPNMIZPvO50s85sISh6bad2a4EaP6Kl90uCoTcnNwIxoL3jqdO7a6Y(kjx8X(eXj0CvxqDl6drUKLmdTMJYSG9Lt5DceZk2NuBk1QSFNbW)Anprd7r8pZbad2aiySdc3)8enShXxcIUhDaCoGOSBaDhGTbqXoTc9lnJ5vZajMqIW(kjx8X(TxzFa3cI7DclzgATLYSG9Lt5DceZk2NuBk1QSFNbW)Anprd7r8pZbad2aiySdc3)8enShXxcIUhDaCoGOSBaDhGTbOMbsmHeH9vsU4J9B4IibClCA(kHLmdTUxmlyF5uENaXSI9vsU4J9j6rexG)1ASpP2uQvzF(xR5PPwoCb5lbr3JoaomGOgGTbW9aOyNwH(LMX8QzGetiryF(xRfofryFAQLdxqSKzyu2XSG9Lt5DceZk2NuBk1QSFNbW)Anpn1YHlipnvsKbWHbe1aGbBa8VwZttTC4cYxcIUhDaCIAaw6a6oaBdGAkoxi1cTK0bWjQbWLwRY7epTfsTqljDa2gqNbKAHwsFUisiXbOvgGXdWGb0DaW1aOMIZfsTqljDaCoacMMdOhgG1(OZ(kjx8X(0uRM6CSKzyugWSG9Lt5DceZk2NuBk1QSFNbKQtU0ttTC4cYlNY7eObyBaDga)R180ulhUG80ujrgahgqudagSbW)Anpn1YHliFji6E0bWjQbe9byBa8VwZRfrVLemFoQwEAQKidGddWshq3bad2a4EaP6Kl90ulhUG8YP8obAa2gqNbW)AnVwe9wsW85OA5PPsImaomalDaWGna(xR5jAypI)zoGUdO7aSnaQP4CHul0ss90uRM6CdGddGlTwL3jEAlKAHws6aSna(xR5DVtRGGyI7lfICPNMkjYamEa8VwZtXoTccIjUVuiYLEAQKidGddO3dW2a4FTMNIDAfeetCFPqKl90ujrgahgqudW2a4FTM39oTccIjUVuiYLEAQKidGddiQbyBaDga3dqHJuBkEAwIgzp0bAQf1x6fzaWGnaUha)R18enShX)mhamydG7bywcxEAQf9vOLb0DaWGnGul0s6ZfrcjoaTYa4aQbiwIqEPeYfrgaCnaLML6cM4(snGEya92Ubad2a4EauStRq)sZyE1mqIjKiSVsYfFSpn1I(k0clzggL1mlyF5uENaXSI9j1MsTk7Z)Anprd7r8pZbyBa8VwZt0WEeFji6E0bWHbGMa5rulza2gGchP2u80SenYEOd0ulQV0lYaSnaiC6rW4RTL4lbr3Joaohqji6Eu2xj5Ip2N(U2wclzggvumlyF5uENaXSI9j1MsTk7Z)Anprd7r8pZbyBa8VwZt0WEeFji6E0bWHbGMa5rulza2gGchP2u80SenYEOd0ulQV0lc7RKCXh7JGXxBlHLmdJQ3mlyF5uENaXSI9vsU4J9PVRTLW(KAtPwL9lPvcnMY7KbyBaQzGetirgGTb0CyCnGodi1cTK(CrKqIdqRmGEyaDgG1daUga1uCUqmLMYa6oGUdaUga1uCUqQfAjPdGtudGiRBaDgqZHX1a6maRhqpmaQP4CHul0sshq3baxdWaF0hq3by8aSEaW1aOMIZfsTqljDa2gqNbqnfNlKAHws6a4CagmaJhqQo5sF2FVacgFuVCkVtGgamydacNEem(ABj(Cjr2d9a6oaBdOZa4EakCKAtXtZs0i7HoqtTO(sVidagSbW9a4FTMNOH9i(N5aGbBaCpaZs4YtFxBlzaDhGTb0za8VwZt0WEeFji6E0bW5akbr3JoayWga3dG)1AEIg2J4FMdOl7tSN4KqQfAjPmdnGLmdJk6mlyF5uENaXSI9vsU4J9rW4RTLW(KAtPwL9lPvcnMY7KbyBaQzGetirgGTb0CyCnGodi1cTK(CrKqIdqRmGEyaDgG1daUga1uCUqmLMYa6oGUdaUga1uCUqQfAjPdGtudONdW2a6maUhGchP2u80SenYEOd0ulQV0lYaGbBaCpa(xR5jAypI)zoayWga3dWSeU8iy812sgq3byBaDga)R18enShXxcIUhDaCoGsq09OdagSbW9a4FTMNOH9i(N5a6Y(e7jojKAHwskZqdyjZWO6jZc2xoL3jqmRyFLKl(yFAkoNwHMtlH9j1MsTk7xsReAmL3jdW2auZajMqImaBdO5W4AaDgqQfAj95IiHehGwza9Wa6maRhaCnaQP4CHyknLb0DaDhaNOgq0hGTb0zaCpafosTP4PzjAK9qhOPwuFPxKbad2a4Ea8VwZt0WEe)ZCaWGnaUhGzjC5PP4CAfAoTKb0L9j2tCsi1cTKuMHgWsMHrXrzwW(YP8obIzf7tQnLAv2xndKycjc7RKCXh7Fs)acgFSKzyuwkZc2xoL3jqmRyFsTPuRY(QzGetiryFLKl(y)yQRfqW4JLmdJQxmlyF5uENaXSI9j1MsTk7RMbsmHeH9vsU4J9BpNlGGXhlzg2B7ywW(YP8obIzf7tQnLAv2N)1AEk2PvqqmX9LcrU0ttLezaCyarnaBdOZauZajMqImayWga)R18U3PvqqmX9LcrU0ttLezaOgqudO7aSnGodOZa4FTMVVw1IRaUfe37e)ZCaWGna(xR5DVtRGGyI7lfICP)zoayWga1uCUqQfAjPdGtudW6byBaCpa(xR5PyNwbbXe3xke5s)ZCaDhGTb0zaCpafosTP4PzjAK9qhOPwuFPxKbad2a4Ea8VwZt0WEe)ZCaDhamydqHJuBkEAwIgzp0bAQf1x6fza2ga)R18enShX)mhGTbywcxEk2PvOFPzSb0L9vsU4J9DVtRanRnIWsMH92aMfSVCkVtGywX(KAtPwL9v4i1MINMLOr2dDGMAr9LErgahgqudagSbW9a4FTMNOH9i(N5aGbBaCpaZs4YtXoTc9lnJX(kjx8X(uStRq)sZySKzyVTMzb7RKCXh7tFxBlH9Lt5DceZkwYs23SecgHxtMfmdnGzb7lNY7eiMvSKzO1mlyF5uENaXSILmdJIzb7lNY7eiMvSKzyVzwW(YP8obIzf7JnzFQKSVsYfFSpxATkVtyFUu3ty)EZ(CPv4ueH9PTqQfAjPSKzy0zwW(YP8obIzf7JnzFfcI9vsU4J95sRv5Dc7ZL6Ec7Ba7tQnLAv2xHJuBkETi6TKG5Zr1YlNY7ei2NlTcNIiSpTfsTqljLLmd7jZc2xoL3jqmRyFSj7RqqSVsYfFSpxATkVtyFUu3tyFdyFsTPuRY(P6Kl90ulhUG8YP8obI95sRWPic7tBHul0sszjZqokZc2xoL3jqmRyFSj7RqqSVsYfFSpxATkVtyFUu3tyFdyFsTPuRY(kCKAtXtZs0i7HoqtTO(sVidGZby9aSnafosTP41IO3scMphvlVCkVtGyFU0kCkIW(0wi1cTKuwYm0szwW(YP8obIzf7JnzF6JN9vsU4J95sRv5Dc7ZL6Ec7Ba7tQnLAv2N7bKQtU0N93lGGXh1lNY7ei2NlTcNIiSpTfsTqljLLmd7fZc2xj5Ip2hbJVi7fA4cH9Lt5DceZkwYm0a7ywW(YP8obIzflzgAGbmlyFLKl(yFtCU4J9Lt5DceZkwYm0aRzwW(kjx8X(uStRq)sZySVCkVtGywXswYs2NlPOl(ygATDg0l76P1r3BxVmi6SFFTU9qtz)OnetCLc0aSEakjx8na3stQFIZ(utHWm0a7SM9nlCBDc7B5byL60JidaUVEl0e3YdiwMM0Of8WJEZypEpbJapDrEonx8rkTLWtxec8tClpG4VtgG19YObyTDg0RbendWo7IwrzPt8jULhahpMEOfA0AIB5bendaUbbjqd4JDAnaRefXpXT8aIMbWXJPhAbAaPwOLmSTbquQqhqIhaXEItcPwOLK6N4wEarZaGBqCShnfObqBHul0sshaxATkVtgqdxdqHGW3aO2FPAj(jULhq0mG)Iy62M9daUbhP2ugqw6MdWHXrEM0b0bcF9OCapQmG3DcrOuTSFaCP1Q8ozau7VuTKU(jULhq0mGECbbZLana4UlxIZ(b8n3AZbqWh0Ml(gqdxdGJloHMR6gaCZTOpe5s4odWE8Rh5CdiMYLmGnhaUgG943a6JVEuoa6EezarB3jfxAkdyPdi2IoMudWSwCTP9(j(e3YdOhZseYlfObWlnCjdGGr41Ca8c69O(ba3ieXmPd4Wx0etlK2ZnaLKl(OdaFo79tCLKl(OEZsiyeEnr1CknYexj5IpQ3SecgHxtJrbFdJHM4kjx8r9MLqWi8AAmk41hAe5snx8nXN4wEa)uRM6CdGRb8tTOVcTmGul0soaYlXT2exj5IpQ3SecgHxtJrbpxATkVtm6uebfTfsTqlj1iUu3tq17jUsYfFuVzjemcVMgJcEU0AvENy0PickAlKAHwsQrytukeKrCPUNGYaJ2gkfosTP41IO3scMphvlVCkVtGM4kjx8r9MLqWi8AAmk45sRv5DIrNIiOOTqQfAjPgHnrPqqgXL6EckdmABOs1jx6PPwoCb5Lt5Dc0exj5IpQ3SecgHxtJrbpxATkVtm6uebfTfsTqlj1iSjkfcYiUu3tqzGrBdLchP2u80SenYEOd0ulQV0lcNwBtHJuBkETi6TKG5Zr1YlNY7eOjUsYfFuVzjemcVMgJcEU0AvENy0PickAlKAHwsQrytu0hVrCPUNGYaJ2gkUt1jx6Z(7fqW4J6Lt5Dc0exj5IpQ3SecgHxtJrbpcgFr2l0WfYeFIB5b8p1KgdNdO0fAa8VwtGgan1KoaEPHlzaemcVMdGxqVhDa6bnaZsIgtCM7HEalDaq4t8tCLKl(OEZsiyeEnngf80tnPXWzGMAsN4kjx8r9MLqWi8AAmk4nX5IVjUsYfFuVzjemcVMgJcEk2PvOFPzSj(e3YdOhZseYlfObiCjL9dixezazmzakjX1aw6auU01P8oXpXvsU4JIIIDAf4ffzIRKCXh1yuWBIZfFgTnu8VwZt0WEeFji6Euo75exj5IpQXOGN3HXqH2RS3OTHI)1AEIg2J4FMtCLKl(OgJcEEPOsfzp0gTnu8VwZt0WEe)ZCIRKCXh1yuWRfrpjK4QKlnABO4FTMNOH9i(N5exj5IpQXOG3TOJL0ah7bHgrU0OTHI)1AEIg2J4FMtCLKl(OgJc(2wcVdJHmABO4FTMNOH9i(N5exj5IpQXOGxpIqZsDbI6CgTnu8VwZt0WEe)ZCIpXT8a44W90jUsYfFuJrb)JkHnfeJofrqXRoPTLe4l9iXmABOeoYBnnfiVbrVx9mk7SrWyheU)5jAypIVeeDpkNrz3exj5IpQXOG)rLWMcIrNIiOGkrHcODk0QjUObEfcTy02qjCK3AAkqEd6Pb9YoRTrWyheU)5jAypIVeeDpkNrz3exj5IpQXOG)rLWMcIrNIiOu48kjJHPb6EOfOGP7HOOfJ2gkHJ8wttbYBqpnikokh1gbJDq4(NNOH9i(sq09OCgLDtCLKl(OgJc(hvcBkigDkIGkxiHM4cjqWqILy02qjCK3AAkqEd6z0JohTNtCLKl(OgJc(hvcBkiuJ2gkcg7GW9pprd7r8LGO7r5mk7M4kjx8rngf88omgkGBHmMeKtqS3OTHIGXoiC)Zt0WEeFji6EuoJYUjUsYfFuJrbpIGGl7d4wW9iluaQefHA02qbHtp9DTTeFji6EuonWoBq40JGXxBlXxcIUhLtdSZwhUt1jx6PP4CAfAoTeVCkVtGGbdcNEAkoNwHMtlXxcIUhLtdSRRnU5FTMNOH9i(NPToknl1fmX9LIdwhDyWiySdc3)8enShXxcIUhLZOSR7exj5IpQXOG38vBZ(9qh4DknN4kjx8rngf81AA6KWEbQPsKjUsYfFuJrbpbFe5Ystbk0CkImXvsU4JAmk4Zys4D843bfA4IigTnu8VwZxcjItO0qdxeX)mHblxeHdrFIRKCXh1yuW3hxoiUK9cLqXNEezIRKCXh1yuW3WKhvGckCKAtjWlkYexj5IpQXOGh9tlOvVaUfu4ifoJnXvsU4JAmk4Zy46OtCLKl(OgJc((AvlUc4wqCVtM4wEakjx8rngf87DsXLMIrBdLchP2u8ULlXzFGAU1ME5uENazRdbJDq4(NFpIwNMl(8LGO7r5G1WGrWyheU)5jItO5QUG6w0hICPVeeDpkhmW6UtCLKl(OgJc(9iADAU4ZOTHIB(xR5jAypI)zARd)R18iccUSpGBb3JSqbOsueQ)zcdwNoem2bH7FEebbx2hWTG7rwOaujkc1xcIUhLtRTdgmUfkvoI4reeCzFa3cUhzHcqLOiupIYXWvxBQzGetirSP0SuxWe3xkor1B7621wh(xR5reeCzFa3cUhzHcqLOiu)Zegm1mqIjKiDTbHtp9DTTeFji6EuoTuBq40JGXxBlXxcIUhLtdS2whiC6PP4CAfAoTeFji6Euo7jmyCNQtU0ttX50k0CAjE5uENa1DIRKCXh1yuWteNqZvDb1TOpe5sJ2gkU5FTMNOH9i(NPTo8VwZJii4Y(aUfCpYcfGkrrO(NjmyD6qWyheU)5reeCzFa3cUhzHcqLOiuFji6EuoT2oyW4wOu5iIhrqWL9bCl4EKfkavIIq9ikhdxDTPMbsmHeXMsZsDbtCFP4evVTRBxBD4wHJuBkE3YL4Spqn3AtVCkVtGGbJ)1AE3YL4Spqn3At)ZSRToq40tFxBlXxcIUhLtRTbHtpcgFTTeFUKi7H2whiC6PP4CAfAoTeFUKi7HggmUt1jx6PP4CAfAoTeVCkVtG62DIRKCXh1yuW3EL9bCliU3jgTnuD4FTMNOH9i(Njmyem2bH7FEIg2J4lbr3JYzu211gf70k0V0mMxndKycjYexj5IpQXOGVHlIeWTWP5ReJ2gQo8VwZt0WEe)Zegmcg7GW9pprd7r8LGO7r5mk76AtndKycjYeFIB5b8nLdsk6exj5IpQXOGNOhrCb(xRz0PickAQLdxqgTnu8VwZttTC4cYxcIUhLdrzJBk2PvOFPzmVAgiXesKjUsYfFuJrbpn1QPoNrBdvh(xR5PPwoCb5PPsIWHOGbJ)1AEAQLdxq(sq09OCIYs7AJAkoxi1cTKuorXLwRY7epTfsTqlj1wNul0s6ZfrcjoaTIXg0fUOMIZfsTqljLtcMM9G1(OpXvsU4JAmk4PPw0xHwmABO6KQtU0ttTC4cYlNY7eiBD4FTMNMA5WfKNMkjchIcgm(xR5PPwoCb5lbr3JYjQOBJ)1AETi6TKG5Zr1YttLeHdwAxyW4ovNCPNMA5WfKxoL3jq26W)AnVwe9wsW85OA5PPsIWblfgm(xR5jAypI)z2TRnQP4CHul0ss90uRM6CCGlTwL3jEAlKAHwsQn(xR5DVtRGGyI7lfICPNMkjIX8VwZtXoTccIjUVuiYLEAQKiCO324FTMNIDAfeetCFPqKl90ujr4qu24FTM39oTccIjUVuiYLEAQKiCikBD4wHJuBkEAwIgzp0bAQf1x6fbgmU5FTMNOH9i(NjmyCBwcxEAQf9vOLUWGLAHwsFUisiXbOv4akXseYlLqUicCP0SuxWe3xQEO32bdg3uStRq)sZyE1mqIjKitCLKl(OgJcE67ABjgTnu8VwZt0WEe)Z0g)R18enShXxcIUhLdOjqEe1sSPWrQnfpnlrJSh6an1I6l9IydcNEem(ABj(sq09OCwcIUhDIRKCXh1yuWJGXxBlXOTHI)1AEIg2J4FM24FTMNOH9i(sq09OCanbYJOwInfosTP4PzjAK9qhOPwuFPxKj(e3YdaUhBbDIRKCXh1yuWtFxBlXiI9eNesTqljfLbgTnuL0kHgt5DIn1mqIjKi2AomU6KAHwsFUisiXbOv6HowdxutX5cXuAkD7cxutX5cPwOLKYjkISUonhgxDSUhOMIZfsTqljTlCzGp6Dn2A4IAkoxi1cTKuBDOMIZfsTqljLtdmovNCPp7VxabJpQxoL3jqWGbHtpcgFTTeFUKi7HURToCRWrQnfpnlrJSh6an1I6l9Iadg38VwZt0WEe)ZegmUnlHlp9DTTKU26W)Anprd7r8LGO7r5SeeDpkmyCZ)Anprd7r8pZUtCLKl(OgJcEem(ABjgrSN4KqQfAjPOmWOTHQKwj0ykVtSPMbsmHeXwZHXvNul0s6ZfrcjoaTsp0XA4IAkoxiMstPBx4IAkoxi1cTKuor1tBD4wHJuBkEAwIgzp0bAQf1x6fbgmU5FTMNOH9i(NjmyCBwcxEem(ABjDT1H)1AEIg2J4lbr3JYzji6EuyW4M)1AEIg2J4FMDN4kjx8rngf80uCoTcnNwIre7jojKAHwskkdmABOkPvcnMY7eBQzGetirS1CyC1j1cTK(CrKqIdqR0dDSgUOMIZfIP0u62Ltur3whUv4i1MINMLOr2dDGMAr9LErGbJB(xR5jAypI)zcdg3MLWLNMIZPvO50s6oXN4wEar7LtknXfDIRKCXh1yuWFs)acgFgTnuQzGetirM4kjx8rngf8XuxlGGXNrBdLAgiXesKjUsYfFuJrbF75Cbem(mABOuZajMqImXvsU4JAmk4DVtRanRnIy02qX)Anpf70kiiM4(sHix6PPsIWHOS1rndKycjcmy8VwZ7ENwbbXe3xke5spnvseur11wNo8VwZ3xRAXva3cI7DI)zcdg)R18U3PvqqmX9LcrU0)mHbJAkoxi1cTKuorzTnU5FTMNIDAfeetCFPqKl9pZU26WTchP2u80SenYEOd0ulQV0lcmyCZ)Anprd7r8pZUWGPWrQnfpnlrJSh6an1I6l9IyJ)1AEIg2J4FM2mlHlpf70k0V0mw3jUsYfFuJrbpf70k0V0mMrBdLchP2u80SenYEOd0ulQV0lchIcgmU5FTMNOH9i(NjmyCBwcxEk2PvOFPzSj(e3YdiAN6CzS6nGgUgacMlbrUCIRKCXh1yuWtFxBlHLSKXa]] )


end