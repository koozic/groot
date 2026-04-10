package com.groot.app.cart;

import java.util.List;

/**
 * 관심제품 Service
 * DAO 호출 + 비즈니스 로직 처리
 * Servlet은 Service만 호출, DB는 모름
 */
public class FavoriteService {

    private final FavoriteDAO dao = new FavoriteDAO();

    // ──────────────────────────────────────────────
    // 장바구니 담기 (INSERT)
    // 반환: "added" | "already" | "error"
    // ──────────────────────────────────────────────
    public String addFavorite(String userId, int productId) {
        // 이미 담겼는지 먼저 체크
        if (dao.isFavorite(userId, productId)) {
            return "already";
        }
        int result = dao.insert(userId, productId);
        return result > 0 ? "added" : "error";
    }

    // ──────────────────────────────────────────────
    // 장바구니 빼기 (DELETE) - favoriteId로
    // ──────────────────────────────────────────────
    public boolean removeFavorite(long favoriteId, String userId) {
        return dao.delete(favoriteId, userId) > 0;
    }

    // ──────────────────────────────────────────────
    // 찜 토글 (있으면 삭제, 없으면 추가)
    // 반환: "added" | "removed" | "error"
    // ──────────────────────────────────────────────
    public String toggleFavorite(String userId, int productId) {
        if (dao.isFavorite(userId, productId)) {
            int result = dao.deleteByProduct(userId, productId);
            return result > 0 ? "removed" : "error";
        } else {
            int result = dao.insert(userId, productId);
            return result > 0 ? "added" : "error";
        }
    }

    // ──────────────────────────────────────────────
    // 내 장바구니 전체 조회 (SELECT)
    // ──────────────────────────────────────────────
    public List<FavoriteVO> getMyFavorites(String userId) {
        return dao.selectAll(userId);
    }

    // ──────────────────────────────────────────────
    // 장바구니 개수
    // ──────────────────────────────────────────────
    public int getFavoriteCount(String userId) {
        return dao.countByUser(userId);
    }

    // ──────────────────────────────────────────────
    // 찜 여부 확인
    // ──────────────────────────────────────────────
    public boolean isFavorite(String userId, int productId) {
        return dao.isFavorite(userId, productId);
    }
}
