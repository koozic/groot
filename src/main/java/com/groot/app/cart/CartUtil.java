package com.groot.app.cart;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import javax.servlet.http.HttpSession;
import java.lang.reflect.Type;
import java.util.List;
import java.util.Map;

public class CartUtil {
    private static final FavoriteService service = new FavoriteService();

    public static void refreshCartCount(HttpSession session, String userId) {
        int count = service.getFavoriteCount(userId);
        session.setAttribute("cartCount", count);
    }

    public static void mergeLocalCart(HttpSession session, String localJson, String userId) {
        if (localJson == null || localJson.trim().isEmpty()) {
            refreshCartCount(session, userId);
            return;
        }
        try {
            Gson gson = new Gson();
            Type listType = new TypeToken<List<Map<String, Object>>>(){}.getType();
            List<Map<String, Object>> items = gson.fromJson(localJson, listType);
            for (Map<String, Object> item : items) {
                if (item.get("productId") == null) continue;
                int productId = ((Number) item.get("productId")).intValue();
                service.addFavorite(userId, productId);
            }
        } catch (Exception e) { e.printStackTrace(); }
        refreshCartCount(session, userId);
    }
}
