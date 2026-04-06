package com.groot.app.recommendCW1;

import lombok.*;

import java.util.List;

/**
 * 분석 결과 VO
 * 세 가지 분석기(My/Deficiency/Compatibility)가 공통으로 반환하는 그릇
 */
@NoArgsConstructor
@Data
@AllArgsConstructor
public class AnalysisResult {

    private boolean success;
    private String  message;

    // 1. 좋은 조합
    private List<ComboItem> goodCombo;

    // 2. 부족한 영양소
    private List<MissingItem> missing;

    // 3. 복용 시간 추천
    private List<TimingItem> timing;

    // 4. 상성 결과 (호환/비호환)
    private List<CompatItem> compatibility;

    // ── 내부 클래스들 ──────────────────────────

    public static class ComboItem {
        public String combo;
        public String effect;
        public ComboItem(String combo, String effect) {
            this.combo  = combo;
            this.effect = effect;
        }
    }

    public static class MissingItem {
        public String icon;
        public String name;
        public String reason;
        public MissingItem(String icon, String name, String reason) {
            this.icon   = icon;
            this.name   = name;
            this.reason = reason;
        }
    }

    public static class TimingItem {
        public String icon;
        public String name;
        public String when;
        public TimingItem(String icon, String name, String when) {
            this.icon = icon;
            this.name = name;
            this.when = when;
        }
    }

    public static class CompatItem {
        public String suppA;
        public String suppB;
        public String status;   // "good" | "bad" | "neutral"
        public String reason;
        public CompatItem(String suppA, String suppB, String status, String reason) {
            this.suppA   = suppA;
            this.suppB   = suppB;
            this.status  = status;
            this.reason  = reason;
        }
    }

    // ── Getter / Setter ────────────────────────

}
