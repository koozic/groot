package com.groot.app.recommendCW1;

import java.util.ArrayList;
import java.util.List;

/**
 * 영양제 분석기 추상 클래스 (부모)
 *
 * 공통 로직: checkGoodCombo / checkTiming / checkConflict
 * 각 자식이 analyze() 를 다르게 구현 (다형성)
 *
 * 비회원/회원 모두 분석 가능
 * → 저장은 RecommendServlet 에서 로그인 여부 확인 후 처리
 */
public abstract class SupplementAnalyzer {

    // ── 자식이 반드시 구현해야 하는 메서드 ──────────
    public abstract AnalysisResult analyze(List<String> supplements);

    // ── 공통 로직 (자식이 그대로 쓰거나 override 가능) ──

    /**
     * 좋은 조합 분석
     */
    protected List<AnalysisResult.ComboItem> checkGoodCombo(List<String> supps) {
        List<AnalysisResult.ComboItem> list = new ArrayList<>();

        if (has(supps, "vitC", "iron"))
            list.add(new AnalysisResult.ComboItem(
                    "비타민C + 철분",
                    "비타민C가 철분 흡수율을 최대 3배 높여줘요"));

        if (has(supps, "vitD", "calcium"))
            list.add(new AnalysisResult.ComboItem(
                    "비타민D + 칼슘",
                    "비타민D가 칼슘을 뼈로 안내해줘요"));

        if (has(supps, "omega3", "vitD"))
            list.add(new AnalysisResult.ComboItem(
                    "오메가3 + 비타민D",
                    "심혈관 건강과 면역력에 시너지"));

        if (has(supps, "magnesium", "vitB"))
            list.add(new AnalysisResult.ComboItem(
                    "마그네슘 + 비타민B",
                    "에너지 대사 + 피로회복 효과"));

        if (has(supps, "zinc", "vitC"))
            list.add(new AnalysisResult.ComboItem(
                    "아연 + 비타민C",
                    "환절기 면역력 강화에 최고 조합"));

        if (list.isEmpty())
            list.add(new AnalysisResult.ComboItem(
                    "선택한 영양제",
                    "특별히 충돌하는 조합은 없어요 👍"));

        return list;
    }

    /**
     * 복용 시간 추천
     */
    protected List<AnalysisResult.TimingItem> checkTiming(List<String> supps) {
        List<AnalysisResult.TimingItem> list = new ArrayList<>();

        // 지용성 → 식사 중
        if (hasAny(supps, "omega3", "vitD", "vitA", "vitE"))
            list.add(new AnalysisResult.TimingItem(
                    "🍽️", "식사 중 복용",
                    "오메가3·비타민D·A·E는 지용성 → 밥 먹을 때 같이"));

        // 수용성 → 아침 식후
        if (hasAny(supps, "vitC", "vitB"))
            list.add(new AnalysisResult.TimingItem(
                    "🌅", "아침 식후 복용",
                    "비타민C·B군은 수용성 → 아침에 먹으면 하루 활력"));

        // 칼슘 → 저녁
        if (hasAny(supps, "calcium"))
            list.add(new AnalysisResult.TimingItem(
                    "🌙", "저녁 식후 복용",
                    "칼슘은 저녁에 흡수가 잘 되고 수면에도 도움"));

        // 마그네슘 → 취침 전
        if (hasAny(supps, "magnesium"))
            list.add(new AnalysisResult.TimingItem(
                    "😴", "취침 30분 전",
                    "마그네슘은 긴장 완화 → 숙면에 도움"));

        // 철분 → 공복
        if (hasAny(supps, "iron"))
            list.add(new AnalysisResult.TimingItem(
                    "☕", "공복 복용 권장",
                    "철분은 공복 흡수율 높음, 커피·차는 2시간 간격"));

        return list;
    }

    /**
     * 충돌 조합 경고
     */
    protected List<AnalysisResult.CompatItem> checkConflict(List<String> supps) {
        List<AnalysisResult.CompatItem> list = new ArrayList<>();

        if (has(supps, "calcium", "iron"))
            list.add(new AnalysisResult.CompatItem(
                    "칼슘", "철분", "bad",
                    "같이 먹으면 서로 흡수를 방해해요. 2시간 간격 권장"));

        if (has(supps, "zinc", "iron"))
            list.add(new AnalysisResult.CompatItem(
                    "아연", "철분", "bad",
                    "흡수 경쟁이 생겨요. 아침/저녁으로 나눠 드세요"));

        if (has(supps, "vitD", "calcium"))
            list.add(new AnalysisResult.CompatItem(
                    "비타민D", "칼슘", "good",
                    "비타민D가 칼슘 흡수를 크게 높여줘요"));

        if (has(supps, "vitC", "iron"))
            list.add(new AnalysisResult.CompatItem(
                    "비타민C", "철분", "good",
                    "비타민C가 철분 흡수율을 극적으로 높여요"));

        return list;
    }

    /**
     * 부족한 영양소 추천
     */
    protected List<AnalysisResult.MissingItem> checkMissing(List<String> supps) {
        List<AnalysisResult.MissingItem> list = new ArrayList<>();

        if (!supps.contains("vitD"))
            list.add(new AnalysisResult.MissingItem(
                    "☀️", "비타민D",
                    "현대인에게 가장 많이 부족. 면역·뼈 건강에 필수"));

        if (!supps.contains("magnesium"))
            list.add(new AnalysisResult.MissingItem(
                    "🌿", "마그네슘",
                    "300가지 이상의 효소 반응에 관여. 수면·피로에 효과"));

        if (supps.contains("calcium") && !supps.contains("vitD"))
            list.add(new AnalysisResult.MissingItem(
                    "🦴", "비타민K2",
                    "칼슘이 뼈로 가도록 안내해주는 역할"));

        if (supps.contains("omega3") && !supps.contains("vitE"))
            list.add(new AnalysisResult.MissingItem(
                    "🌰", "비타민E",
                    "오메가3 산화를 막아 효과를 유지해줘요"));

        return list;
    }

    // ── 헬퍼 메서드 ─────────────────────────────

    /** 두 영양제가 모두 있는지 */
    protected boolean has(List<String> supps, String a, String b) {
        return supps.contains(a) && supps.contains(b);
    }

    /** 하나라도 있는지 */
    protected boolean hasAny(List<String> supps, String... targets) {
        for (String t : targets)
            if (supps.contains(t)) return true;
        return false;
    }
}
