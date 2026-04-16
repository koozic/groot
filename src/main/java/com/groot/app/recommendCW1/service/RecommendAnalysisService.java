package com.groot.app.recommendCW1.service;

import com.groot.app.recommendCW1.AnalysisResult;
import com.groot.app.recommendCW1.dao.RecommendPairRuleDAO;
import com.groot.app.recommendCW1.dao.RecommendSupplementDAO;
import com.groot.app.recommendCW1.dto.RecommendPairRuleDTO;
import com.groot.app.recommendCW1.dto.RecommendSupplementDTO;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class RecommendAnalysisService {
    public static final RecommendAnalysisService SERVICE = new RecommendAnalysisService();

    private static final List<String> FEATURED_NAMES = Arrays.asList(
            "비타민 C", "비타민 D", "오메가3", "칼슘",
            "마그네슘", "철분", "아연", "프로바이오틱스"
    );

    private final RecommendSupplementDAO supplementDAO = RecommendSupplementDAO.DAO;
    private final RecommendPairRuleDAO pairRuleDAO = RecommendPairRuleDAO.DAO;

    private RecommendAnalysisService() {
    }

    public List<RecommendSupplementDTO> getAllSupplements() {
        return supplementDAO.getAllSupplements();
    }

    public List<RecommendSupplementDTO> getFeaturedSupplements(List<RecommendSupplementDTO> allSupplements) {
        List<RecommendSupplementDTO> featured = new ArrayList<>();
        Set<Integer> usedIds = new LinkedHashSet<>();

        for (String featuredName : FEATURED_NAMES) {
            for (RecommendSupplementDTO supplement : allSupplements) {
                if (normalizeName(featuredName).equals(normalizeName(supplement.getSupplementName()))
                        && usedIds.add(supplement.getSupplementId())) {
                    featured.add(supplement);
                    break;
                }
            }
        }

        for (RecommendSupplementDTO supplement : allSupplements) {
            if (featured.size() >= 8) {
                break;
            }
            if (usedIds.add(supplement.getSupplementId())) {
                featured.add(supplement);
            }
        }

        return featured;
    }

    public List<RecommendSupplementDTO> getMoreSupplements(List<RecommendSupplementDTO> allSupplements) {
        Set<Integer> featuredIds = getFeaturedSupplements(allSupplements).stream()
                .map(RecommendSupplementDTO::getSupplementId)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        return allSupplements.stream()
                .filter(supplement -> !featuredIds.contains(supplement.getSupplementId()))
                .collect(Collectors.toList());
    }

    public List<String> resolveSelectedSupplementIds(String[] rawValues, List<RecommendSupplementDTO> allSupplements) {
        List<String> selectedIds = new ArrayList<>();
        if (rawValues == null || rawValues.length == 0) {
            return selectedIds;
        }

        Map<Integer, RecommendSupplementDTO> supplementsById = allSupplements.stream()
                .collect(Collectors.toMap(RecommendSupplementDTO::getSupplementId, supplement -> supplement, (a, b) -> a, LinkedHashMap::new));

        Map<String, List<Integer>> idsByNormalizedName = new LinkedHashMap<>();
        for (RecommendSupplementDTO supplement : allSupplements) {
            idsByNormalizedName
                    .computeIfAbsent(normalizeName(supplement.getSupplementName()), key -> new ArrayList<>())
                    .add(supplement.getSupplementId());
        }

        Set<String> uniqueIds = new LinkedHashSet<>();
        for (String rawValue : rawValues) {
            if (rawValue == null || rawValue.isBlank()) {
                continue;
            }

            String normalized = normalizeName(rawValue);
            if (isNumeric(normalized)) {
                int id = Integer.parseInt(normalized);
                if (supplementsById.containsKey(id)) {
                    uniqueIds.add(String.valueOf(id));
                    continue;
                }
            }

            if (idsByNormalizedName.containsKey(normalized)) {
                idsByNormalizedName.get(normalized).forEach(id -> uniqueIds.add(String.valueOf(id)));
                continue;
            }

            for (Integer id : mapLegacyCodeToIds(normalized, idsByNormalizedName)) {
                uniqueIds.add(String.valueOf(id));
            }
        }

        selectedIds.addAll(uniqueIds);
        return selectedIds;
    }

    public AnalysisResult analyze(List<String> rawSelectedIds, String type) {
        AnalysisResult result = new AnalysisResult();
        List<RecommendSupplementDTO> allSupplements = getAllSupplements();
        List<String> normalizedIds = resolveSelectedSupplementIds(
                rawSelectedIds == null ? null : rawSelectedIds.toArray(new String[0]),
                allSupplements
        );

        if (normalizedIds.isEmpty()) {
            result.setSuccess(false);
            result.setMessage("영양제를 선택해주세요");
            return result;
        }

        List<Integer> selectedIds = normalizedIds.stream()
                .map(Integer::parseInt)
                .collect(Collectors.toList());

        Map<Integer, RecommendSupplementDTO> supplementsById = allSupplements.stream()
                .collect(Collectors.toMap(RecommendSupplementDTO::getSupplementId, supplement -> supplement, (a, b) -> a, LinkedHashMap::new));

        Set<Integer> selectedSet = new LinkedHashSet<>(selectedIds);
        List<AnalysisResult.ComboItem> goodCombos = buildGoodCombos(selectedSet);
        List<AnalysisResult.MissingItem> missingItems = buildMissingItems(selectedSet);
        List<AnalysisResult.TimingItem> timingItems = buildTimingItems(selectedIds, supplementsById);
        List<AnalysisResult.CompatItem> compatItems = buildCompatibilityItems(selectedSet);

        if (goodCombos.isEmpty()) {
            goodCombos.add(new AnalysisResult.ComboItem("선택한 영양제", "조합 데이터가 더 쌓이면 더 자세한 시너지 정보를 보여드릴게요."));
        }

        result.setSuccess(true);
        result.setGoodCombo(goodCombos);
        result.setMissing(missingItems);
        result.setTiming(timingItems);
        result.setCompatibility(compatItems);
        return result;
    }

    private List<AnalysisResult.ComboItem> buildGoodCombos(Set<Integer> selectedSet) {
        List<AnalysisResult.ComboItem> list = new ArrayList<>();

        for (RecommendPairRuleDTO pair : pairRuleDAO.getGoodPairRules()) {
            if (selectedSet.contains(pair.getSupplementId1()) && selectedSet.contains(pair.getSupplementId2())) {
                list.add(new AnalysisResult.ComboItem(
                        pair.getSupplementName1() + " + " + pair.getSupplementName2(),
                        pair.getReason()
                ));
            }
        }

        return list;
    }

    private List<AnalysisResult.MissingItem> buildMissingItems(Set<Integer> selectedSet) {
        Map<Integer, AnalysisResult.MissingItem> itemMap = new LinkedHashMap<>();

        for (RecommendPairRuleDTO pair : pairRuleDAO.getGoodPairRules()) {
            boolean hasFirst = selectedSet.contains(pair.getSupplementId1());
            boolean hasSecond = selectedSet.contains(pair.getSupplementId2());

            if (hasFirst == hasSecond) {
                continue;
            }

            int missingId = hasFirst ? pair.getSupplementId2() : pair.getSupplementId1();
            String missingName = hasFirst ? pair.getSupplementName2() : pair.getSupplementName1();

            itemMap.putIfAbsent(
                    missingId,
                    new AnalysisResult.MissingItem(resolveSupplementIcon(missingName), missingName, pair.getReason())
            );
        }

        return new ArrayList<>(itemMap.values());
    }

    private List<AnalysisResult.TimingItem> buildTimingItems(List<Integer> selectedIds,
                                                             Map<Integer, RecommendSupplementDTO> supplementsById) {
        List<AnalysisResult.TimingItem> list = new ArrayList<>();

        for (Integer selectedId : selectedIds) {
            RecommendSupplementDTO supplement = supplementsById.get(selectedId);
            if (supplement == null) {
                continue;
            }

            String timing = blankToDefault(supplement.getSupplementTiming(), "복용 시간 정보 준비 중");
            String caution = cleanupText(supplement.getSupplementCaution());
            String when = caution.isBlank() ? timing : timing + " · " + shorten(caution, 72);

            list.add(new AnalysisResult.TimingItem(
                    resolveTimingIcon(timing, caution),
                    supplement.getSupplementName(),
                    when
            ));
        }

        return list;
    }

    private List<AnalysisResult.CompatItem> buildCompatibilityItems(Set<Integer> selectedSet) {
        List<AnalysisResult.CompatItem> list = new ArrayList<>();

        for (RecommendPairRuleDTO pair : pairRuleDAO.getGoodPairRules()) {
            if (selectedSet.contains(pair.getSupplementId1()) && selectedSet.contains(pair.getSupplementId2())) {
                list.add(new AnalysisResult.CompatItem(
                        pair.getSupplementName1(),
                        pair.getSupplementName2(),
                        "good",
                        pair.getReason()
                ));
            }
        }

        for (RecommendPairRuleDTO pair : pairRuleDAO.getBadPairRules()) {
            if (selectedSet.contains(pair.getSupplementId1()) && selectedSet.contains(pair.getSupplementId2())) {
                String reason = pair.getReason();
                if (pair.getIntervalHours() != null && pair.getIntervalHours() > 0) {
                    reason += " " + pair.getIntervalHours() + "시간 간격으로 드시는 편이 좋아요.";
                }

                list.add(new AnalysisResult.CompatItem(
                        pair.getSupplementName1(),
                        pair.getSupplementName2(),
                        "bad",
                        reason
                ));
            }
        }

        return list;
    }

    private List<Integer> mapLegacyCodeToIds(String rawValue,
                                             Map<String, List<Integer>> idsByNormalizedName) {
        return switch (rawValue) {
            case "vita" -> idsByNormalizedName.getOrDefault("비타민 a", List.of());
            case "vitc" -> idsByNormalizedName.getOrDefault("비타민 c", List.of());
            case "vitd" -> idsByNormalizedName.getOrDefault("비타민 d", List.of());
            case "vite" -> idsByNormalizedName.getOrDefault("비타민 e", List.of());
            case "omega3" -> idsByNormalizedName.getOrDefault("오메가3", List.of());
            case "magnesium" -> idsByNormalizedName.getOrDefault("마그네슘", List.of());
            case "calcium" -> idsByNormalizedName.getOrDefault("칼슘", List.of());
            case "iron" -> idsByNormalizedName.getOrDefault("철분", List.of());
            case "zinc" -> idsByNormalizedName.getOrDefault("아연", List.of());
            case "vitb" -> findFirstVitaminB(idsByNormalizedName);
            default -> List.of();
        };
    }

    private List<Integer> findFirstVitaminB(Map<String, List<Integer>> idsByNormalizedName) {
        for (Map.Entry<String, List<Integer>> entry : idsByNormalizedName.entrySet()) {
            if (entry.getKey().startsWith("비타민 b")) {
                return entry.getValue().isEmpty() ? List.of() : List.of(entry.getValue().get(0));
            }
        }
        return List.of();
    }

    private String resolveTimingIcon(String timing, String caution) {
        String normalizedTiming = normalizeName(timing);
        String normalizedCaution = normalizeName(caution);

        if (normalizedTiming.contains("공복")) {
            return "☕";
        }
        if (normalizedTiming.contains("기상") || normalizedTiming.contains("아침")) {
            return "🌅";
        }
        if (normalizedTiming.contains("점심")) {
            return "☀️";
        }
        if (normalizedTiming.contains("저녁")) {
            return "🌙";
        }
        if (normalizedTiming.contains("운동")) {
            return "💪";
        }
        if (normalizedTiming.contains("취침") || normalizedCaution.contains("숙면")) {
            return "😴";
        }
        if (normalizedTiming.contains("식전")) {
            return "🥄";
        }
        return "🍽️";
    }

    private String resolveSupplementIcon(String supplementName) {
        String normalizedName = normalizeName(supplementName);

        if (normalizedName.contains("비타민 c")) {
            return "🍋";
        }
        if (normalizedName.contains("비타민 d")) {
            return "☀️";
        }
        if (normalizedName.contains("비타민 e")) {
            return "🌰";
        }
        if (normalizedName.contains("오메가")) {
            return "🐟";
        }
        if (normalizedName.contains("마그네슘")) {
            return "🌿";
        }
        if (normalizedName.contains("철분")) {
            return "🩸";
        }
        if (normalizedName.contains("칼슘")) {
            return "🦴";
        }
        if (normalizedName.contains("아연")) {
            return "🛡️";
        }
        if (normalizedName.contains("프로바이오틱스")) {
            return "🦠";
        }

        return "💊";
    }

    private String normalizeName(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    private boolean isNumeric(String value) {
        return value != null && value.matches("\\d+");
    }

    private String blankToDefault(String value, String defaultValue) {
        return value == null || value.isBlank() ? defaultValue : value;
    }

    private String cleanupText(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("<br>", " ")
                .replace("\r", " ")
                .replace("\n", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private String shorten(String value, int maxLength) {
        if (value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength - 3) + "...";
    }
}
