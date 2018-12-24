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


    spec:RegisterStateExpr( "ap_check", function ()
        local a = this_action
        a = a and action[ this_action ]
        a = a and a.ap_check
    
        return a == true
    end )


    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = { 
        "force_of_nature", "full_moon", "half_moon", "lunar_strike", "moonfire", "new_moon", "solar_wrath", "starfall", "starsurge", "sunfire"
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

            ap_check = function()
                return astral_power.current - action.force_of_nature.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,
            
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

            ap_check = function()
                return astral_power.current - action.full_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.half_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,
            
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
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,
            
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
            
            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,
            
            usable = false,
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

            ap_check = function()
                return astral_power.current - action.lunar_strike.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )
                removeStack( "warrior_of_elune" )

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
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function()
                return astral_power.current + 3 + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,                        
            
            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
                gain( 3, "astral_power" )
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
            
            ap_check = function()
                return astral_power.current - action.new_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            usable = function () return target.casting end,
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
            
            ap_check = function()
                return astral_power.current - action.solar_wrath.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            usable = function () return debuff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeDebuff( "target", "dispellable_enrage" )
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
            
            ap_check = function()
                return astral_power.current - action.starfall.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.starsurge.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.stellar_flare.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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

            pvptalent = "thorns",
            
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


    spec:RegisterPack( "Balance", 20181219.1613, [[dCeVLaqiLupcq6susYMOknkLKtPeTkHs5vqQMfLu3IQO2fv(LKQHrjXXaOLju8ma00ucCnHs12ae9naLACuf5CacwNsqnpa4EqY(ucDqHsAHqkpeqrtKssDrHsOnkuc6JkbPoPqjALcXoPegkGswkGcpfOPsj6QkbjBvOeyVq9xbdwvhg1IvQhJ0KjYLjTzj(mLYOfQoTkRwjiETqA2eUnv1Ub9BkgorTCPEoIPl66qSDkvFxsz8acDEavRNQW8LK9RymGylXGsCQylIXka6jaJbqGGdqGeqacWyhdMaxwXGYmnkBtXGq2xXGOXcgsvmOmdCHHLWwIbjgKMQyW4zktw461TDzCKTJA8RtoFebNNbsBUK1jNpT(wy213f2ZsQ96YTPCcLuhy1kWGpjsDGfWiy1nYjfqJfmKQoY5tXGBKtKXsiEJbL4uXweJva0tagdGabhGajGacqGedYizCtJbbpFGjgm(jjPq8gdkPekgeOZJglyivN3QBKtAIa05JNPmzHRx32LXr2oQXVo58reCEgiT5swNC(06BHzxFxyplP2Rl3MYjusDGvRad(Ki1bwaJGv3iNuanwWqQ6iNpDIa05TALQ(BTNhqGG1ZhJva0tZ755beixyRaSNiteGopWmodTPKfEIa05988XQKKknpOrW98OPSVBIa05988aZ4m0MknFYTnndxzEktuY8PzEkWPcnKCBttIBIa05988XQ0cbHKQ08Ksi52MMK5TZ9XBHoFX0ZZssg48eGdtgi6MiaDEppFSkjPsZVqr05JLP6tCyqXrsc2smOKwyerITeBbGylXGmnpdedsmcUdBL9XGkK3cvcJgoXwed2smOc5TqLWOHbP9LAFmgCJukokhoi1HiJbzAEgigu2KNbItSfaeBjguH8wOsy0WG0(sTpgdUrkfhLdhK6qKXGmnpdedUfgJuOG0ahNylwa2smOc5TqLWOHbP9LAFmgCJukokhoi1HiJbzAEgigCRnr7Oh0goXwe7ylXGkK3cvcJggK2xQ9XyWnsP4OC4GuhImgKP5zGyqUPmudPPBfM4eBbqITedQqElujmAyqAFP2hJb3iLIJYHdsDiYyqMMNbIbfNT4jjSqqKS5RWeNyla2ylXGkK3cvcJggK2xQ9XyWnsP4OC4GuhImgKP5zGyWY16wyms4eBHNWwIbviVfQegnmiTVu7JXGBKsXr5WbPoezmitZZaXGmKQKSzrGYcboXwaeWwIbviVfQegnmiTVu7JXGuJrizQbDuoCqQRvF(GK5xCEaAfmitZZaXGienCP6tWj2caTc2smitZZaXG14UpthmLGkqGkguH8wOsy0Wj2cabeBjguH8wOsy0WG0(sTpgdYEO9LQtC2vbWde5RV0PqEluP59o)Q5PgJqYud6oiLBiNNb6A1NpizEamFmZxvnp1yesMAqhvfkjpweyXzd6RW01QpFqY8ayEaJz(LyqMMNbIbpiuB7CQ4eBbGXGTedQqElujmAyqAFP2hJbzs2SiiBQP98lIA(fyfmitZZaXGhKYnKZZaXj2cabi2smOc5TqLWOHbP9LAFmgKjzZIGSPM2ZViQ5xGvM378RMF98ShAFP6eNDva8ar(6lDkK3cvA(QQ53iLItC2vbWde5RV0Hip)Y59o)Q53iLIJKClmTKJKmn68lIA(yMVQA(1ZNSqHPJKClmTKtH8wOsZxvn)65TZ9XBH6ypceY8lXGmnpdedsvHsYJfbwC2G(kmXj2caxa2smOc5TqLWOHbP9LAFmgC18BKsXr5WbPoe55RQMNAmcjtnOJYHdsDT6ZhKm)IZdqRm)Y59opXi4ouR5mUJLd04knkgKP5zGyWcsd8GPeubcuXj2caJDSLyqfYBHkHrdds7l1(ym4Q53iLIJYHdsDiYZxvnp1yesMAqhLdhK6A1Npiz(fNhGwz(LZ7DEwoqJR0OyqMMNbIblMMQbtja5ePvCITaqGeBjguH8wOsy0WG0(sTpgdUrkfhj5wyAjxR(8bjZdG5908ENF98eJG7qTMZ4owoqJR0OyqMMNbIbPmKQIWgPuWGBKsjazFfdssUfMwcNylaeyJTedQqElujmAyqAFP2hJbxn)gPuCKKBHPLCKKPrNhaZdW5RQMFJukosYTW0sUw95dsMFruZ7P5xoV35jYQqesUTPjz(frnVDUpEluhPesUTPjzEVZVA(KBBA6YZxdPjiD68OppGZVC(yBEISkeHKBBAsMFX5PgsoVvnFmUyhdY08mqmij5UWcboXwaONWwIbviVfQegnmiTVu7JXGRMpzHcthj5wyAjNc5TqLM378RMFJukosYTW0sosY0OZdG5b48vvZVrkfhj5wyAjxR(8bjZViQ5908ENFJukoUPm8ObzebHBhjzA05bW8EA(LZxvn)65twOW0rsUfMwYPqEluP59o)Q53iLIJBkdpAqgrq42rsMgDEamVNMVQA(nsP4OC4GuhI88lNF58ENNiRcri52MMehj5UWcX8ayE7CF8wOosjKCBttY8ENFJukobcK7G6lBQPTVcthjzA05rF(nsP4igb3b1x2utBFfMosY0OZdG5xW8ENFJukoIrWDq9Ln102xHPJKmn68ayEaoV353iLItGa5oO(YMAA7RW0rsMgDEampaN378RMF9825(4TqDShbcz(QQ5xp)gPuCuoCqQdrE(QQ5xpVCR2DKKBcsBtNF58vvZNCBttxE(AinbPtNhaOMxbIkfj1qE(68X28mjBweKn10EERA(fyL5RQMF98eJG7qTMZ4owoqJR0OyqMMNbIbjj3eK2MItSfaceWwIbviVfQegnmitZZaXGeey5Afds7l1(ymyRLwjX5TqN378RMNLd04kn68ENVimME(vZNCBttxE(AinbPtN3QMppA0qE(68lNp2MNiRcri52MMK5xe18lyE0NNiRcri52MMK59o)Q5jYQqesUTPjz(fNhW5rF(KfkmDzTdg8ngiXPqEluP5RQMxYKoFJbwUwD5rJEqBZVCEVZVA(1ZBN7J3c1XEeiK5RQMF98BKsXr5WbPoe55RQMF98YTA3rqGLR15xo)smif4uHgsUTPjbBbG4eBrmwbBjguH8wOsy0WGmnpded6BmWY1kgK2xQ9XyWwlTsIZBHoV35xnplhOXvA059oFrym98RMp52MMU881qAcsNoVvnFE0OH8815xoFSnprwfIqYTnnjZViQ5bY59o)Q5xpVDUpEluh7rGqMVQA(1ZVrkfhLdhK6qKNVQA(1Zl3QDNVXalxRZVC(LyqkWPcnKCBttc2caXj2IyaeBjguH8wOsy0WGmnpdedssvi4oueCRyqAFP2hJbBT0kjoVf68ENF18SCGgxPrN378fHX0ZVA(KBBA6YZxdPjiD68w185rJgYZxNF58lIAEGCEVZVA(1ZBN7J3c1XEeiK5RQMF98BKsXr5WbPoe55RQMF98YTA3rsvi4oueCRZVC(LyqkWPcnKCBttc2caXj2IyIbBjguH8wOsy0WG0(sTpgdYYbACLgfdY08mqmiuRf8ngioXwedaXwIbviVfQegnmiTVu7JXGSCGgxPrXGmnpdedgNfLGVXaXj2Iywa2smOc5TqLWOHbP9LAFmgKLd04knkgKP5zGyWcIqe8ngioXwetSJTedQqElujmAyqAFP2hJb3iLIJyeChuFztnT9vy6ijtJopaMhGZ7D(vZZYbACLgD(QQ53iLItGa5oO(YMAA7RW0rsMgDEuZdW5xoV35xn)Q53iLIRg39z6GPeubcuDiYZxvn)gPuCcei3b1x2utBFfMoe55RQMNiRcri52MMK5xe18XmV35xp)gPuCeJG7G6lBQPTVcthI88vvZBN7J3c1XEeKiZ7D(1ZVrkfNexdEqBbcc0Hip)Y59o)Q5xpVDUpEluh7rGqMVQA(1ZVrkfhLdhK6qKNVQA(vZVEE5wT7eiqUdKSVO68ENF98jluy6oiLBiNNb6uiVfQ08vvZl3QDhXi4ouR5m(8lNF58vvZBN7J3c1XEeiK59o)gPuCuoCqQdrEEVZl3QDhXi4ouR5m(8lXGmnpdedkqGChizFrvCITigGeBjguH8wOsy0WG0(sTpgdAN7J3c1XEeiK5bW8aC(QQ5xp)gPuCuoCqQdrE(QQ5xpVCR2DeJG7qTMZ4yqMMNbIbjgb3HAnNXXj2Iya2ylXGmnpdedsqGLRvmOc5TqLWOHtCIbLBLA83CITeBbGylXGkK3cvcJgoXwed2smOc5TqLWOHtSfaeBjguH8wOsy0Wj2IfGTedQqElujmAyq7SarXGShAFP6izRC0dAlqsUjUMHrXGmnpdedAN7J3cfdAN7aK9vmi7rGqWj2IyhBjguH8wOsy0WG2zbIIbzp0(s1jX1Gh0wGGaDndJIbzAEgig0o3hVfkg0o3bi7Ryq2JGebNylasSLyqfYBHkHrddANfikgK9q7lvh3ugE0GmIGWTRzyumitZZaXG25(4TqXG25oazFfdYEeyzCITayJTedQqElujmAyqJmgKOjgKP5zGyq7CF8wOyq7SarXGlyE0NF18jluy6YAhm4BmqItH8wOsZ7D(vZZEO9LQJBkdpAqgrq42PqEluP5RQMpzHcthj5wyAjNc5TqLMF58lN3ZZVA(1ZZEO9LQJBkdpAqgrq42PqEluP59o)65twOW0rsUfMwYPqEluP59oFYcfMosQcb3bP(kPtH8wOsZVedAN7aK9vmiPesUTPjbNyl8e2smitZZaXG(gdm6bdft7JbviVfQegnCITaiGTedQqElujmA4eBbGwbBjgKP5zGyqztEgiguH8wOsy0Wj2cabeBjgKP5zGyqIrWDOwZzCmOc5TqLWOHtCItmODTjNbITigRaONamgaJDxmacymyWACdpOncgmw6lB6uLMpM5zAEg48IJKe3ebdk3MYjumiqNhnwWqQoVv3iN0ebOZhptzYcxVUTlJJSDuJFDY5Ji48mqAZLSo58P13cZU(UWEwsTxxUnLtOK6aRwbg8jrQdSagbRUroPaASGHu1roF6ebOZB1kv93AppGabRNpgRaONM3ZZdiqUWwbyprMiaDEGzCgAtjl8ebOZ755JvjjvAEqJG75rtzF3ebOZ755bMXzOnvA(KBBAgUY8uMOK5tZ8uGtfAi52MMe3ebOZ755JvPfccjvP5jLqYTnnjZBN7J3cD(IPNNLKmW5jahMmq0nra68EE(yvssLMFHIOZhlt1N4MiteGoFSiquPiPkn)wlMwNNA83Co)wTDqIB(yLsv5Kmp0a9CCU9liI5zAEgizEduaC3eHP5zGeNCRuJ)MtufbtIoryAEgiXj3k14V5eDu1lgJ0eHP5zGeNCRuJ)Mt0rvNrS5RWKZZaNiaD(y1dTVuNpwa3hVfkzIW08mqItUvQXFZj6OQBN7J3c1Ai7ROypceI12zbIII9q7lvhjBLJEqBbsYnX1mm6eHP5zGeNCRuJ)Mt0rv3o3hVfQ1q2xrXEeKiwBNfikk2dTVuDsCn4bTfiiqxZWOteMMNbsCYTsn(BorhvD7CF8wOwdzFff7rGLT2olquuShAFP64MYWJgKreeUDndJora68Gj3fwiM3(8Gj3eK2MoFYTnnNNIKMszIW08mqItUvQXFZj6OQBN7J3c1Ai7ROiLqYTnnjwBKrr00A7SarrTa0xLSqHPlRDWGVXajofYBHk5Df7H2xQoUPm8ObzebHBNc5TqLQQswOW0rsUfMwYPqEluPLl98Q1ShAFP64MYWJgKreeUDkK3cvY76KfkmDKKBHPLCkK3cvYBYcfMosQcb3bP(kPtH8wOslNimnpdK4KBLA83CIoQ6(gdm6bdft7pra68GqwMe3KZ38jn)gPuuP5jjNK53AX068uJ)MZ53QTdsMNHsZl3QNLnzEqBZFK5Lmq1nryAEgiXj3k14V5eDu1jqwMe3KbsYjzIW08mqItUvQXFZj6OQlBYZaNimnpdK4KBLA83CIoQ6eJG7qTMZ4tKjcqNpweiQuKuLMxTRnWNppFD(mUoptttp)rMNTZNG3c1nryAEgibfXi4oSv2FIW08mqc6OQlBYZaT(kO2iLIJYHdsDiYteMMNbsqhv9TWyKcfKg4wFfuBKsXr5WbPoe5jctZZajOJQ(wBI2rpOnRVcQnsP4OC4GuhI8eHP5zGe0rvNBkd1qA6wHP1xb1gPuCuoCqQdrEIW08mqc6OQloBXtsyHGizZxHP1xb1gPuCuoCqQdrEIW08mqc6OQxUw3cJrY6RGAJukokhoi1HipryAEgibDu1zivjzZIaLfcRVcQnsP4OC4GuhI8ezIa05bMwnzIW08mqc6OQJq0WLQpX6RGIAmcjtnOJYHdsDT6ZhKSiaTYeHP5zGe0rvVg39z6GPeubcuNimnpdKGoQ6heQTDovRVck2dTVuDIZUkaEGiF9LofYBHk5Df1yesMAq3bPCd58mqxR(8bjaiMQkQXiKm1GoQkusESiWIZg0xHPRvF(GeaaymlNimnpdKGoQ6hKYnKZZaT(kOys2SiiBQP9IOwGvMimnpdKGoQ6uvOK8yrGfNnOVctRVckMKnlcYMAAViQfyfVRwZEO9LQtC2vbWde5RV0PqEluPQQnsP4eNDva8ar(6lDiYl9UAJukosYTW0sosY0OlIkMQQ1jluy6ij3ctl5uiVfQuv1A7CF8wOo2JaHSCIW08mqc6OQxqAGhmLGkqGQ1xb1QnsP4OC4GuhICvf1yesMAqhLdhK6A1NpizraALLEjgb3HAnNXDSCGgxPrNimnpdKGoQ6ftt1GPeGCI0Q1xb1QnsP4OC4GuhICvf1yesMAqhLdhK6A1NpizraALLEz5anUsJorMiaDEqzfkPnzIW08mqc6OQtzivfHnsPynK9vuKKBHPLS(kO2iLIJKClmTKRvF(Gea4jVRjgb3HAnNXDSCGgxPrNimnpdKGoQ6KK7clewFfuR2iLIJKClmTKJKmnkaayv1gPuCKKBHPLCT6ZhKSikpT0lrwfIqYTnnjlIYo3hVfQJucj320K4DvYTnnD55RH0eKofDaxgBezvicj320KSi1qsRkgxSpryAEgibDu1jj3eK2MA9vqTkzHcthj5wyAjNc5TqL8UAJukosYTW0sosY0OaaGvvBKsXrsUfMwY1QpFqYIO8K3nsP44MYWJgKreeUDKKPrbGNwwvTozHcthj5wyAjNc5TqL8UAJukoUPm8ObzebHBhjzAua4PQQnsP4OC4GuhI8YLEjYQqesUTPjXrsUlSqaa7CF8wOosjKCBttI3nsP4eiqUdQVSPM2(kmDKKPrrFJukoIrWDq9Ln102xHPJKmnkawG3nsP4igb3b1x2utBFfMosY0OaaGE3iLItGa5oO(YMAA7RW0rsMgfaa07Q125(4TqDShbcPQA9gPuCuoCqQdrUQATCR2DKKBcsBtxwvLCBttxE(AinbPtbakfiQuKud55RXgtYMfbztnTTQfyLQQ1eJG7qTMZ4owoqJR0OtKjcqN3QnwsMimnpdKGoQ6eey5A1AkWPcnKCBttckaT(kOAT0kjoVfQ3vSCGgxPr9wegtVk52MMU881qAcsNAv5rJgYZxxgBezvicj320KSiQfGorwfIqYTnnjExrKvHiKCBttYIaIEYcfMUS2bd(gdK4uiVfQuvLKjD(gdSCT6YJg9G2w6D1A7CF8wOo2JaHuvTEJukokhoi1HixvTwUv7occSCTUC5eHP5zGe0rv33yGLRvRPaNk0qYTnnjOa06RGQ1sRK48wOExXYbACLg1Brym9QKBBA6YZxdPjiDQvLhnAipFDzSrKvHiKCBttYIOasVRwBN7J3c1XEeiKQQ1BKsXr5WbPoe5QQ1YTA35BmWY16YLteMMNbsqhvDsQcb3HIGB1AkWPcnKCBttckaT(kOAT0kjoVfQ3vSCGgxPr9wegtVk52MMU881qAcsNAv5rJgYZxxUikG07Q125(4TqDShbcPQA9gPuCuoCqQdrUQATCR2DKufcUdfb36YLtKjcqNFHwHAZPPjteMMNbsqhvDOwl4BmqRVckwoqJR0OteMMNbsqhv94SOe8ngO1xbflhOXvA0jctZZajOJQEbric(gd06RGILd04kn6eHP5zGe0rvxGa5oqY(IQwFfuBKsXrmcUdQVSPM2(kmDKKPrbaa9UILd04knAv1gPuCcei3b1x2utBFfMosY0OOa4sVRwTrkfxnU7Z0btjOceO6qKRQ2iLItGa5oO(YMAA7RW0HixvrKvHiKCBttYIOIX76nsP4igb3b1x2utBFfMoe5Qk7CF8wOo2JGeX76nsP4K4AWdAlqqGoe5LExT2o3hVfQJ9iqivvR3iLIJYHdsDiYvvRwl3QDNabYDGK9fv9UozHct3bPCd58mqNc5TqLQQKB1UJyeChQ1CgF5YQk7CF8wOo2JaH4DJukokhoi1Hi7vUv7oIrWDOwZz8LteMMNbsqhvDIrWDOwZzCRVck7CF8wOo2JaHaaawvTEJukokhoi1HixvTwUv7oIrWDOwZz8jYebOZhlKfImEJmFX0Z7BSR(kmNimnpdKGoQ6eey5AfdsKvk2caTsm4eNym]] )

    
end