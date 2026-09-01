package org.dromara.shanheng.support;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * USDA FoodData Central 营养查询客户端。
 * <p>
 * 用途：管理端「联网补全」菜品营养时，用英文食材关键词查询 USDA，
 * 提取每 100g 的蛋白质/脂肪/碳水（营养素编号 1003/1004/1005）。
 * <p>
 * 说明：USDA 仅支持英文关键词，因此内置中英食材词典做映射；
 * 中式菜品覆盖有限，补全失败时可人工指定英文关键词或在管理端手工填写营养。
 *
 * @author shanheng
 */
@Slf4j
@Component
public class USDAFoodClient {

    private static final String API_URL = "https://api.nal.usda.gov/fdc/v1/foods/search";

    /** USDA 营养素编号：蛋白质 / 脂肪 / 碳水化合物 */
    private static final int NUTRIENT_PROTEIN = 1003;
    private static final int NUTRIENT_FAT = 1004;
    private static final int NUTRIENT_CARBS = 1005;

    /** 中英食材词典（覆盖种子数据与常见食材），匹配时按 key 长度降序 */
    private static final Map<String, String> CN_EN = new LinkedHashMap<>();

    static {
        CN_EN.put("鸡胸肉丝", "chicken breast");
        CN_EN.put("鸡胸肉", "chicken breast");
        CN_EN.put("鸡腿肉", "chicken thigh");
        CN_EN.put("西兰花", "broccoli");
        CN_EN.put("圣女果", "cherry tomato");
        CN_EN.put("橄榄油", "olive oil");
        CN_EN.put("鲈鱼", "sea bass");
        CN_EN.put("姜", "ginger");
        CN_EN.put("葱", "scallion");
        CN_EN.put("蒸鱼豉油", "soy sauce");
        CN_EN.put("糙米", "brown rice");
        CN_EN.put("藜麦", "quinoa");
        CN_EN.put("番茄", "tomato");
        CN_EN.put("鸡蛋", "egg");
        CN_EN.put("面条", "noodles");
        CN_EN.put("青菜", "bok choy");
        CN_EN.put("上海青", "bok choy");
        CN_EN.put("小米", "millet");
        CN_EN.put("南瓜", "pumpkin");
        CN_EN.put("枸杞", "goji berry");
        CN_EN.put("牛油果", "avocado");
        CN_EN.put("生菜", "lettuce");
        CN_EN.put("黄瓜", "cucumber");
        CN_EN.put("牛肉", "beef");
        CN_EN.put("豆芽", "bean sprouts");
        CN_EN.put("芹菜", "celery");
        CN_EN.put("辣椒", "chili pepper");
        CN_EN.put("基围虾", "shrimp");
        CN_EN.put("虾", "shrimp");
        CN_EN.put("燕麦", "oats");
        CN_EN.put("牛奶", "milk");
        CN_EN.put("蓝莓", "blueberry");
        CN_EN.put("香菇", "shiitake mushroom");
        CN_EN.put("菌菇", "mushroom");
        CN_EN.put("蒜", "garlic");
        CN_EN.put("冬瓜", "winter melon");
        CN_EN.put("排骨", "pork ribs");
        CN_EN.put("薏米", "barley");
        CN_EN.put("豆腐", "tofu");
        CN_EN.put("花椒", "sichuan pepper");
        CN_EN.put("豆瓣酱", "broad bean paste");
        CN_EN.put("红薯", "sweet potato");
        CN_EN.put("紫薯", "purple sweet potato");
        CN_EN.put("香菜", "cilantro");
        CN_EN.put("荞麦面", "buckwheat noodles");
        CN_EN.put("胡萝卜", "carrot");
        CN_EN.put("菠菜", "spinach");
        CN_EN.put("猪肝", "pork liver");
        CN_EN.put("土豆", "potato");
        CN_EN.put("玉米", "corn");
        CN_EN.put("红枣", "red dates");
        CN_EN.put("银耳", "snow fungus");
        CN_EN.put("莲子", "lotus seed");
        CN_EN.put("山药", "yam");
    }

    @Value("${shanheng.usda.api-key:DEMO_KEY}")
    private String apiKey;

    /** 营养查询结果 */
    public static class Nutrition {
        public BigDecimal protein;
        public BigDecimal fat;
        public BigDecimal carbs;
        public String description;
        public Long fdcId;
    }

    /**
     * 根据中文菜品名 + 食材 JSON 推导 USDA 英文查询词。
     * 优先匹配食材词典，其次匹配菜品名，最后校验纯英文名。
     */
    public String resolveKeyword(String name, String ingredientsJson) {
        for (String c : parseIngredients(ingredientsJson)) {
            String en = matchDict(c);
            if (en != null) {
                return en;
            }
        }
        String en = matchDict(name);
        if (en != null) {
            return en;
        }
        if (StrUtil.isNotBlank(name) && name.matches("^[a-zA-Z ,]+$")) {
            return name.trim();
        }
        return null;
    }

    /**
     * 查询 USDA，返回每 100g 的三大营养素；无结果返回 null。
     */
    public Nutrition search(String keyword) {
        String body = doSearch(keyword, "Foundation,SR%20Legacy");
        Nutrition nutrition = parse(body);
        if (nutrition == null) {
            // 降级：不过滤数据类型再查一次
            body = doSearch(keyword, null);
            nutrition = parse(body);
        }
        return nutrition;
    }

    private String doSearch(String keyword, String dataType) {
        HttpRequest request = HttpRequest.get(API_URL)
            .form("query", keyword)
            .form("pageSize", 1)
            .form("api_key", apiKey)
            .timeout(15000);
        if (StrUtil.isNotBlank(dataType)) {
            request.form("dataType", dataType);
        }
        return request.execute().body();
    }

    private Nutrition parse(String body) {
        if (StrUtil.isBlank(body)) {
            return null;
        }
        JSONObject json = JSONUtil.parseObj(body);
        JSONArray foods = json.getJSONArray("foods");
        if (foods == null || foods.isEmpty()) {
            return null;
        }
        JSONObject food = foods.getJSONObject(0);
        BigDecimal protein = extract(food, NUTRIENT_PROTEIN);
        BigDecimal fat = extract(food, NUTRIENT_FAT);
        BigDecimal carbs = extract(food, NUTRIENT_CARBS);
        if (protein == null && fat == null && carbs == null) {
            return null;
        }
        Nutrition nutrition = new Nutrition();
        nutrition.protein = protein;
        nutrition.fat = fat;
        nutrition.carbs = carbs;
        nutrition.description = food.getStr("description");
        nutrition.fdcId = food.getLong("fdcId");
        return nutrition;
    }

    private BigDecimal extract(JSONObject food, int nutrientId) {
        JSONArray nutrients = food.getJSONArray("foodNutrients");
        if (nutrients == null) {
            return null;
        }
        for (int i = 0; i < nutrients.size(); i++) {
            JSONObject n = nutrients.getJSONObject(i);
            if (n.getInt("nutrientId", -1) == nutrientId) {
                return n.getBigDecimal("value");
            }
        }
        return null;
    }

    private List<String> parseIngredients(String json) {
        List<String> result = new ArrayList<>();
        if (StrUtil.isBlank(json)) {
            return result;
        }
        try {
            JSONArray arr = JSONUtil.parseArray(json);
            for (Object o : arr) {
                if (o != null && StrUtil.isNotBlank(o.toString())) {
                    result.add(o.toString().trim());
                }
            }
        } catch (Exception e) {
            for (String s : json.split("[,，、]")) {
                if (StrUtil.isNotBlank(s)) {
                    result.add(s.trim());
                }
            }
        }
        return result;
    }

    private String matchDict(String text) {
        if (StrUtil.isBlank(text)) {
            return null;
        }
        return CN_EN.entrySet().stream()
            .sorted(Map.Entry.comparingByKey(Comparator.comparingInt(String::length).reversed()))
            .filter(e -> text.contains(e.getKey()))
            .map(Map.Entry::getValue)
            .findFirst()
            .orElse(null);
    }

}