package com.groot.app.mypage;

import com.google.gson.Gson;
import com.groot.app.user.UserDTO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/mypage/sticker")
public class StickerC extends HttpServlet {

    // ── GET: 스티커 불러오기 ──
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        UserDTO loginUser = (UserDTO) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int year = Integer.parseInt(request.getParameter("year"));
        int month = Integer.parseInt(request.getParameter("month"));

        // Model(DAO) 호출
        List<Map<String, Object>> stickers =
                MyPageDAO.MDAO.getStickers(loginUser.getUser_id(), year, month);

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(new Gson().toJson(stickers));
    }

    // ── POST: 스티커 저장 (해당 월 전체를 덮어씀) ──
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        UserDTO loginUser = (UserDTO) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // JSON body 읽기
        String body = request.getReader().lines().collect(Collectors.joining());
        Gson gson = new Gson();
        StickerSaveRequest req = gson.fromJson(body, StickerSaveRequest.class);

        // 해당 월 스티커 전부 삭제 후 재삽입 (심플 구현)
        MyPageDAO.MDAO.deleteStickers(
                loginUser.getUser_id(), req.year, req.month);

        List<Map<String, Object>> saved = new ArrayList<>();
        if (req.stickers != null) {
            for (StickerDTO s : req.stickers) {
                int newId = MyPageDAO.MDAO.insertSticker(
                        loginUser.getUser_id(), s.sticker_type,
                        req.year, req.month, s.cal_day, s.pos_x, s.pos_y);

                saved.add(Map.of(
                        "sticker_id", newId,
                        "sticker_type", s.sticker_type,
                        "cal_year", req.year,
                        "cal_month", req.month,
                        "cal_day", s.cal_day,
                        "pos_x", s.pos_x,
                        "pos_y", s.pos_y
                ));
            }
        }

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(gson.toJson(saved));
    }

    // ── 요청 JSON 매핑용 내부 클래스 ──
    static class StickerSaveRequest {
        int year, month;
        List<StickerDTO> stickers;
    }

    static class StickerDTO {
        String sticker_type;
        int cal_year;    // ← 추가
        int cal_month;   // ← 추가
        int cal_day;
        float pos_x, pos_y;
    }
}