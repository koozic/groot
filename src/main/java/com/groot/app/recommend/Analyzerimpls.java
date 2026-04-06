package com.groot.app.recommend;

import java.util.List;

// ═══════════════════════════════════════════════════
// 1번 기능: 내가 먹는 영양제 분석
//   → 조합 + 복용시간 + 충돌경고 한 번에
// ═══════════════════════════════════════════════════
class MySupplementAnalyzer extends SupplementAnalyzer {

    @Override
    public AnalysisResult analyze(List<String> supplements) {
        AnalysisResult result = new AnalysisResult();

        // 부모 공통 메서드 활용
        result.setGoodCombo(checkGoodCombo(supplements));
        result.setTiming(checkTiming(supplements));
        result.setCompatibility(checkConflict(supplements));
        result.setSuccess(true);

        return result;
    }
}

// ═══════════════════════════════════════════════════
// 2번 기능: 부족한 영양소 추천
//   → 지금 안 먹는 것 중에 필요한 것 추천
// ═══════════════════════════════════════════════════
class DeficiencyAnalyzer extends SupplementAnalyzer {

    @Override
    public AnalysisResult analyze(List<String> supplements) {
        AnalysisResult result = new AnalysisResult();

        // 부족한 영양소 + 같이 먹으면 좋은 조합 힌트
        result.setMissing(checkMissing(supplements));
        result.setGoodCombo(checkGoodCombo(supplements));
        result.setSuccess(true);

        return result;
    }
}

// ═══════════════════════════════════════════════════
// 3번 기능: 두 영양제 상성 확인
//   → 선택한 영양제들 사이의 궁합만 집중
// ═══════════════════════════════════════════════════
class CompatibilityAnalyzer extends SupplementAnalyzer {

    @Override
    public AnalysisResult analyze(List<String> supplements) {
        AnalysisResult result = new AnalysisResult();

        // 충돌 + 좋은 조합 상성만 보여줌
        result.setCompatibility(checkConflict(supplements));
        result.setGoodCombo(checkGoodCombo(supplements));
        result.setTiming(checkTiming(supplements));
        result.setSuccess(true);

        return result;
    }
}
