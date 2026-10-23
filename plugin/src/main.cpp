/*
 * Survival Accord
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt. The DLL is a combined work with CommonLibSSE-NG (GPL-3.0-or-later); see NOTICE.txt.
 *
 * Native helpers for the Survival Accord Papyrus scripts (SurvivalAccordNative.psc):
 *  - does Firmament have this perk, and what is the combined magnitude of one of its active magic effects (Fortify Exploration equipment).
 *  - a placeholder for Hunterborn support ("coming soon").
 * Nothing here patches game or other plugins' code.
 */
#include "PCH.h"

namespace
{
	constexpr auto kFirmament = "FirmamentNewSkills.esp"sv;
	constexpr auto kHunterborn = "Hunterborn.esp"sv;

	std::atomic<bool> g_firmament{ false };
	std::atomic<bool> g_hunterborn{ false };

	std::mutex                                   g_cacheLock;
	std::unordered_map<std::int32_t, RE::BGSPerk*>       g_perks;
	std::unordered_map<std::int32_t, RE::EffectSetting*> g_effects;

	void SetupLog()
	{
		const auto dir = SKSE::log::log_directory();
		if (!dir) {
			return;
		}
		auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>((*dir / "SurvivalAccord.log").string(), true);
		auto log = std::make_shared<spdlog::logger>("SurvivalAccord", std::move(sink));
		log->set_level(spdlog::level::info);
		log->flush_on(spdlog::level::info);
		log->set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%l] %v");
		spdlog::set_default_logger(std::move(log));
	}

	template <class T>
	T* Cached(std::unordered_map<std::int32_t, T*>& a_cache, std::int32_t a_localID)
	{
		std::lock_guard lock(g_cacheLock);
		if (const auto it = a_cache.find(a_localID); it != a_cache.end()) {
			return it->second;
		}
		const auto dh = RE::TESDataHandler::GetSingleton();
		T*         form = dh ? dh->LookupForm<T>(static_cast<RE::FormID>(a_localID), kFirmament) : nullptr;
		a_cache.emplace(a_localID, form);  // a missing form is cached too, so a wrong ID costs one lookup
		return form;
	}

	// ---------- Papyrus: SurvivalAccordNative ----------
	bool IsFirmamentLoaded(RE::StaticFunctionTag*)
	{
		return g_firmament.load();
	}

	bool HasFirmamentPerk(RE::StaticFunctionTag*, RE::Actor* a_actor, std::int32_t a_localID)
	{
		if (!a_actor || !g_firmament.load()) {
			return false;
		}
		const auto perk = Cached(g_perks, a_localID);
		return perk && a_actor->HasPerk(perk);
	}

	float GetFirmamentActiveEffectMagnitude(RE::StaticFunctionTag*, std::int32_t a_localID)
	{
		if (!g_firmament.load()) {
			return 0.0f;
		}
		const auto player = RE::PlayerCharacter::GetSingleton();
		const auto target = player ? player->AsMagicTarget() : nullptr;
		const auto effects = target ? target->GetActiveEffectList() : nullptr;
		const auto wanted = Cached(g_effects, a_localID);
		if (!effects || !wanted) {
			return 0.0f;
		}
		float total = 0.0f;
		for (const auto effect : *effects) {
			if (effect && !effect->flags.any(RE::ActiveEffect::Flag::kInactive) && effect->GetBaseObject() == wanted) {
				total += effect->magnitude;
			}
		}
		return total;
	}

	RE::BSFixedString GetHunterbornStatus(RE::StaticFunctionTag*)
	{
		return "coming soon";
	}

	bool RegisterPapyrus(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("IsFirmamentLoaded", "SurvivalAccordNative", IsFirmamentLoaded);
		a_vm->RegisterFunction("HasFirmamentPerk", "SurvivalAccordNative", HasFirmamentPerk);
		a_vm->RegisterFunction("GetFirmamentActiveEffectMagnitude", "SurvivalAccordNative", GetFirmamentActiveEffectMagnitude);
		a_vm->RegisterFunction("GetHunterbornStatus", "SurvivalAccordNative", GetHunterbornStatus);
		return true;
	}

	void LogEnvironment()
	{
		const auto dh = RE::TESDataHandler::GetSingleton();
		const auto has = [&](std::string_view a_name) { return dh && dh->LookupModByName(a_name) != nullptr; };

		g_firmament = has(kFirmament);
		g_hunterborn = has(kHunterborn);
		SKSE::log::info("Last Seed {}, Frostfall {}, Campfire {}, Firmament {}",
			has("LastSeed.esp"sv) ? "found" : "not found", has("Frostfall.esp"sv) ? "found" : "not found",
			has("Campfire.esm"sv) ? "found" : "not found", g_firmament ? "found" : "not found (its hooks stay neutral)");
		if (g_hunterborn) {
			SKSE::log::info("Hunterborn found: Hunterborn support is coming soon, nothing is changed for it yet");
		}
		if (g_firmament) {
			// Proves the local FormIDs in SA_Firmament.psc still point at the perks and the effect they are meant to: a wrong ID would silently do nothing.
			for (const std::int32_t id : { 16, 17, 18, 19, 20, 22, 23, 24, 25, 26 }) {
				const auto perk = Cached(g_perks, id);
				SKSE::log::info("Firmament perk {:#04x}: {}", id, perk ? perk->GetName() : "NOT FOUND");
			}
			const auto effect = Cached(g_effects, 167);
			SKSE::log::info("Firmament effect {:#04x}: {}", 167, effect ? effect->GetName() : "NOT FOUND");
		}
		// The original "Firmament - Last Seed & Frostfall Compatibility" patch does the same job with its own scripts and DLL.
		for (const auto name : { L"FirmamentLSFFCompat.dll", L"FirmamentFrostfallCompat.dll" }) {
			if (GetModuleHandleW(name)) {
				SKSE::log::error("{} is installed as well. Survival Accord replaces it: disable that mod, or the same scripts will fight over the result", std::filesystem::path(name).string());
			}
		}
	}

	void OnMessage(SKSE::MessagingInterface::Message* a_msg)
	{
		if (a_msg->type == SKSE::MessagingInterface::kDataLoaded) {
			LogEnvironment();
		}
	}
}

SKSEPluginLoad(const SKSE::LoadInterface* a_skse)
{
	SKSE::Init(a_skse);
	SetupLog();
	SKSE::log::info("SurvivalAccord.dll 1.0.1, game {}", REL::Module::get().version().string());
	SKSE::GetPapyrusInterface()->Register(RegisterPapyrus);
	SKSE::GetMessagingInterface()->RegisterListener(OnMessage);
	return true;
}
