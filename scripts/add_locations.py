#!/usr/bin/env python3
"""
Script để thêm nhiều địa điểm lịch sử Việt Nam vào historical_locations.json
"""

import json
import sys
from pathlib import Path

# Thêm các địa điểm mới vào đây
NEW_LOCATIONS = [
    {
        "id": "vietnam-military-history-museum",
        "name": "Bảo tàng Lịch sử Quân sự Việt Nam",
        "lat": 21.031944,
        "lng": 105.841111,
        "description": "Bảo tàng Lịch sử Quân sự Việt Nam là nơi trưng bày các hiện vật, tài liệu về lịch sử quân sự Việt Nam từ thời cổ đại đến hiện đại.",
        "period": "Thời kỳ hiện đại",
        "type": "Bảo tàng",
        "address": "Số 28A, Điện Biên Phủ, Quận Ba Đình, Hà Nội",
        "relatedEvents": ["Lịch sử quân sự Việt Nam"],
        "relatedFigures": [],
        "year": 1959
    },
    {
        "id": "ngoc-son-temple",
        "name": "Đền Ngọc Sơn",
        "lat": 21.031111,
        "lng": 105.852222,
        "description": "Đền Ngọc Sơn là một ngôi đền nằm trên đảo Ngọc của hồ Hoàn Kiếm, Hà Nội. Đây là một trong những di tích lịch sử và văn hóa quan trọng của thủ đô.",
        "period": "Thời kỳ phong kiến",
        "type": "Di tích tôn giáo",
        "address": "Đảo Ngọc, Hồ Hoàn Kiếm, Quận Hoàn Kiếm, Hà Nội",
        "relatedEvents": ["Lịch sử Hà Nội"],
        "relatedFigures": [],
        "year": 1865
    },
    {
        "id": "thang-long-water-puppet",
        "name": "Nhà hát Múa rối nước Thăng Long",
        "lat": 21.028889,
        "lng": 105.852222,
        "description": "Nhà hát Múa rối nước Thăng Long là nơi biểu diễn nghệ thuật múa rối nước truyền thống của Việt Nam, một di sản văn hóa phi vật thể.",
        "period": "Thời kỳ phong kiến",
        "type": "Di tích văn hóa",
        "address": "Số 57B, Đinh Tiên Hoàng, Quận Hoàn Kiếm, Hà Nội",
        "relatedEvents": ["Văn hóa dân gian Việt Nam"],
        "relatedFigures": [],
        "year": 1969
    },
    {
        "id": "ho-chi-minh-museum",
        "name": "Bảo tàng Hồ Chí Minh",
        "lat": 21.036944,
        "lng": 105.834167,
        "description": "Bảo tàng Hồ Chí Minh là nơi trưng bày các hiện vật, tài liệu về cuộc đời và sự nghiệp của Chủ tịch Hồ Chí Minh.",
        "period": "Thời kỳ hiện đại",
        "type": "Bảo tàng",
        "address": "Số 19, Ngọc Hà, Quận Ba Đình, Hà Nội",
        "relatedEvents": ["Cuộc đời Hồ Chí Minh", "Cách mạng Việt Nam"],
        "relatedFigures": ["Hồ Chí Minh"],
        "year": 1990
    },
    {
        "id": "tay-son-rebellion",
        "name": "Phong trào Tây Sơn",
        "lat": 13.766667,
        "lng": 109.216667,
        "description": "Phong trào Tây Sơn là một phong trào nông dân lớn trong lịch sử Việt Nam, đánh bại các thế lực phong kiến và thống nhất đất nước.",
        "period": "Thời kỳ phong kiến",
        "type": "Địa danh lịch sử",
        "address": "Tỉnh Bình Định",
        "relatedEvents": ["Khởi nghĩa Tây Sơn", "Thống nhất đất nước"],
        "relatedFigures": ["Nguyễn Huệ", "Nguyễn Nhạc", "Nguyễn Lữ"],
        "year": 1771
    },
    {
        "id": "battle-of-ngoc-hoi-dong-da",
        "name": "Trận Ngọc Hồi - Đống Đa",
        "lat": 21.016667,
        "lng": 105.833333,
        "description": "Trận Ngọc Hồi - Đống Đa là chiến thắng vĩ đại của quân Tây Sơn dưới sự chỉ huy của Quang Trung, đánh bại quân Thanh năm 1789.",
        "period": "Thời kỳ phong kiến",
        "type": "Địa danh lịch sử",
        "address": "Quận Đống Đa, Hà Nội",
        "relatedEvents": ["Chiến thắng Ngọc Hồi - Đống Đa 1789"],
        "relatedFigures": ["Nguyễn Huệ", "Quang Trung"],
        "year": 1789
    },
    {
        "id": "temple-of-king-le",
        "name": "Đền Vua Lê",
        "lat": 20.433333,
        "lng": 105.966667,
        "description": "Đền Vua Lê là nơi thờ vua Lê Thái Tổ, người lãnh đạo cuộc khởi nghĩa Lam Sơn đánh đuổi quân Minh và lập nên triều Lê.",
        "period": "Thời kỳ phong kiến",
        "type": "Di tích lịch sử",
        "address": "Xã Xuân Lam, Huyện Thọ Xuân, Tỉnh Thanh Hóa",
        "relatedEvents": ["Khởi nghĩa Lam Sơn", "Đánh đuổi quân Minh"],
        "relatedFigures": ["Lê Thái Tổ", "Lê Lợi"],
        "year": 1428
    },
    {
        "id": "lam-son-uprising",
        "name": "Khởi nghĩa Lam Sơn",
        "lat": 20.433333,
        "lng": 105.966667,
        "description": "Khởi nghĩa Lam Sơn là cuộc khởi nghĩa do Lê Lợi lãnh đạo, đánh đuổi quân Minh và giành lại độc lập cho Việt Nam.",
        "period": "Thời kỳ phong kiến",
        "type": "Địa danh lịch sử",
        "address": "Huyện Thọ Xuân, Tỉnh Thanh Hóa",
        "relatedEvents": ["Khởi nghĩa Lam Sơn", "Đánh đuổi quân Minh"],
        "relatedFigures": ["Lê Thái Tổ", "Lê Lợi", "Nguyễn Trãi"],
        "year": 1418
    },
    {
        "id": "battle-of-chi-lang",
        "name": "Trận Chi Lăng",
        "lat": 21.616667,
        "lng": 106.516667,
        "description": "Trận Chi Lăng là chiến thắng vĩ đại của quân Lam Sơn, tiêu diệt chủ tướng Liễu Thăng của quân Minh năm 1427.",
        "period": "Thời kỳ phong kiến",
        "type": "Địa danh lịch sử",
        "address": "Huyện Chi Lăng, Tỉnh Lạng Sơn",
        "relatedEvents": ["Trận Chi Lăng 1427", "Khởi nghĩa Lam Sơn"],
        "relatedFigures": ["Lê Lợi", "Nguyễn Trãi"],
        "year": 1427
    },
    {
        "id": "tran-dynasty-citadel",
        "name": "Thành nhà Trần",
        "lat": 20.266667,
        "lng": 106.016667,
        "description": "Thành nhà Trần là kinh đô của triều Trần, một trong những triều đại hùng mạnh nhất trong lịch sử Việt Nam.",
        "period": "Thời kỳ phong kiến",
        "type": "Di tích lịch sử",
        "address": "Xã An Sinh, Huyện Đông Triều, Tỉnh Quảng Ninh",
        "relatedEvents": ["Triều Trần", "Kháng chiến chống Nguyên Mông"],
        "relatedFigures": ["Trần Thái Tông", "Trần Hưng Đạo"],
        "year": 1225
    }
]

def add_locations(input_file, output_file):
    """Thêm các địa điểm mới vào file JSON"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    existing_ids = {loc['id'] for loc in data['locations']}
    
    # Thêm các địa điểm mới (tránh trùng ID)
    added_count = 0
    for location in NEW_LOCATIONS:
        if location['id'] not in existing_ids:
            data['locations'].append(location)
            existing_ids.add(location['id'])
            added_count += 1
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Đã thêm {added_count} địa điểm mới vào {output_file}")
    print(f"Tổng số địa điểm: {len(data['locations'])}")

if __name__ == '__main__':
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    input_file = project_root / 'assets' / 'historical_locations.json'
    output_file = input_file  # Ghi đè file gốc
    
    if not input_file.exists():
        print(f"File không tồn tại: {input_file}")
        sys.exit(1)
    
    add_locations(input_file, output_file)
