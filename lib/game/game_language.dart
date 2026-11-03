enum GameLanguage {
  vi('vi', 'Tiếng Việt'),
  en('en', 'English');

  const GameLanguage(this.code, this.displayName);
  final String code;
  final String displayName;

  static GameLanguage fromCode(String code) => GameLanguage.values.firstWhere(
    (item) => item.code == code,
    orElse: () => GameLanguage.vi,
  );

  String text(String vietnamese) {
    if (this == GameLanguage.vi) return vietnamese;
    final exact = _english[vietnamese];
    if (exact != null) return exact;
    final activated = RegExp(r'^Đã bật công tắc (\d+)\.$')
        .firstMatch(vietnamese);
    if (activated != null) {
      return 'Star ${activated.group(1)} activated.';
    }
    final order = RegExp(r'^Hãy bật công tắc (\d+) trước\.$')
        .firstMatch(vietnamese);
    if (order != null) {
      return 'Activate star ${order.group(1)} first.';
    }
    if (vietnamese.startsWith('Qua màn ') && vietnamese.endsWith(' để mở.')) {
      return 'Beat stage ${vietnamese.substring('Qua màn '.length, vietnamese.length - ' để mở.'.length)} to unlock.';
    }
    return vietnamese;
  }
}

const _english = <String, String>{
  'RẠP BÓNG NHỎ': 'LITTLE SHADOW THEATRE',
  'Rạp bóng nhỏ': 'Little Shadow Theatre',
  'Một ngọn đèn. Cả thế giới chuyển động.': 'One lamp. A world in motion.',
  'Chơi ngay': 'Play now',
  'Xem màn': 'Browse stages',
  'lượt': 'lives',
  'Cách chơi': 'How to play',
  'Kéo đèn để dẫn bóng\nvề cửa trăng.':
      'Drag the lamp to guide the shadow\nto the moon door.',
  'Tránh vùng đỏ, bật sao\ntheo thứ tự.':
      'Avoid red zones. Activate stars\nin order.',
  'Mỗi lượt có 60 giây.\nTạm dừng sẽ dừng giờ.':
      'Each attempt lasts 60 seconds.\nPause stops the clock.',
  'Đã hiểu': 'Got it',
  'Tắt âm thanh': 'Mute sound',
  'Bật âm thanh': 'Turn on sound',
  'Cài đặt': 'Settings',
  'Ngôn ngữ': 'Language',
  'Chọn ngôn ngữ hiển thị': 'Choose display language',
  'Đóng': 'Close',
  'Đang lưu cài đặt…': 'Saving settings…',
  'Không lưu được ngôn ngữ. Vui lòng thử lại.':
      'Could not save language. Please try again.',
  'Đã khôi phục ván và thời gian còn lại, không trừ thêm lượt.':
      'Your attempt and remaining time were restored without costing a life.',
  'Hết lượt. Đợi hồi lượt hoặc xem quảng cáo thử nghiệm.':
      'No lives left. Wait for a refill or watch a test ad.',
  'Hết lượt. Đợi hồi lượt hoặc xem quảng cáo mô phỏng.':
      'No lives left. Wait for a refill or watch a demo ad.',
  'Tab này chỉ đọc. Hãy quay lại tab đang chơi.':
      'This tab is read only. Return to the tab where you are playing.',
  'Đang có một ván chưa kết thúc.': 'An attempt is already in progress.',
  'Qua màn trước để mở màn này.': 'Beat the previous stage to unlock this one.',
  'Đang xử lý, vui lòng thử lại.': 'Please wait and try again.',
  'Đã nhận +1 lượt.': 'Received +1 life.',
  'Đã đóng quảng cáo thử nghiệm; không nhận lượt.':
      'Test ad closed; no life awarded.',
  'Đã đóng quảng cáo mô phỏng; không nhận lượt.':
      'Demo ad closed; no life awarded.',
  'Quảng cáo hoặc lưu thưởng bị lỗi; không cộng lượt.':
      'Ad or reward save failed; no life awarded.',
  'Lượt đã đầy.': 'Lives are full.',
  'Quảng cáo đang chạy.': 'An ad is already running.',
  'Đặt lại dữ liệu lưu?': 'Reset saved data?',
  'Thao tác này xóa lượt và tiến độ bị lỗi trên thiết bị này.':
      'This removes the damaged lives and progress on this device.',
  'Hủy': 'Cancel',
  'Đặt lại': 'Reset',
  'Xoay dọc để tiếp tục': 'Rotate to portrait to continue',
  'Xoay dọc để chơi': 'Rotate to portrait to play',
  'đang mở': 'open',
  'đang khóa': 'locked',
  'Kéo đèn vàng bằng một ngón để dẫn bóng.':
      'Drag the yellow lamp with one finger to guide the shadow.',
  'Ad chưa cấu hình': 'Ad unavailable',
  'Đang tải ad…': 'Loading ad…',
  'Lượt đã đầy': 'Lives full',
  'Xem ad test\n+1 lượt': 'Watch test ad\n+1 life',
  'Xem quảng cáo\n+1 lượt': 'Watch ad\n+1 life',
  'Hồi sau': 'Refill in',
  'Chưa lưu kết quả': 'Result not saved',
  'Tạm dừng': 'Paused',
  'Qua cửa trăng!': 'Through the moon door!',
  'Hết 60 giây': 'Time is up',
  'Bóng chạm vùng đỏ': 'Shadow touched a red zone',
  'Đồng hồ ván đã dừng. Tiếp tục khi sẵn sàng.':
      'The clock is paused. Continue when ready.',
  'Giữ toàn bộ bóng trong cửa đủ một giây.':
      'Keep the whole shadow inside the door for one second.',
  'Hết giờ tính thua. Thử lại với 60 giây mới.':
      'Time ran out. Try again with a fresh 60 seconds.',
  'Thử đường khác để tránh cảm biến.': 'Try another path around the sensor.',
  'Đang lưu phiên chơi…': 'Saving attempt…',
  'Chưa mở': 'Locked',
  'Hết lượt': 'No lives',
  'Bắt đầu': 'Start',
  'Màn trước': 'Previous',
  'Màn sau': 'Next',
  'Thử lưu lại': 'Retry save',
  'Tiếp tục': 'Continue',
  'Màn tiếp theo': 'Next stage',
  'Chơi lại': 'Play again',
  'Thử lại': 'Retry',
  'Bỏ ván': 'Leave attempt',
  'Quảng cáo mô phỏng': 'Demo ad',
  'Đang tải…': 'Loading…',
  'Đang lưu thưởng…': 'Saving reward…',
  'Xem đủ 5 giây để nhận +1 lượt.': 'Watch for 5 seconds to earn +1 life.',
  'Đang lưu': 'Saving',
  'giây': 'seconds',
  'Đóng · không nhận lượt': 'Close · no reward',
  'Giả lập lỗi tải': 'Simulate load error',
  'Đang đọc phiên chơi…': 'Loading game…',
  'Tab chỉ đọc': 'Read only tab',
  'Không mở được dữ liệu lưu': 'Could not load save',
  'Một tab khác đang chơi. Đóng tab đó rồi tải lại để tiếp tục.':
      'Another tab is playing. Close it and reload to continue.',
  'Vui lòng đợi một chút.': 'Please wait a moment.',
  'Đặt lại dữ liệu lỗi': 'Reset damaged data',
  'Bóng chạm cảm biến đỏ.': 'The shadow touched a red sensor.',
  'Bóng chạm màn chớp.': 'The shadow touched a moving shutter.',
  'Đạo cụ đang chắn đường bóng.': 'A prop is blocking the shadow.',
  'Cửa chắn đang khóa. Hãy chạm công tắc sao.':
      'The gate is locked. Touch the star switch.',
  'Hết 60 giây.': 'Time is up.',
  'Bóng đã qua cửa trăng!': 'The shadow reached the moon door!',
  'Cửa đã khép. Hãy bật lại các sao.':
      'The gate closed. Activate the stars again.',
  'Phiên bản dữ liệu lưu không được hỗ trợ.':
      'This save version is not supported.',
  'Dữ liệu lưu bị lỗi.': 'Saved data is damaged.',
  'Không đọc được dữ liệu lưu.': 'Could not read saved data.',
  'Không lưu được dữ liệu. Vui lòng thử lại.':
      'Could not save data. Please try again.',
  'Tab này chỉ đọc.': 'This tab is read only.',
  'Dữ liệu chưa sẵn sàng.': 'Data is not ready.',
  'Đang lưu lượt chơi.': 'Saving lives.',
  'Đang lưu.': 'Saving.',
  'Thời gian còn lại không hợp lệ.': 'Remaining time is invalid.',
  'Reward ID không hợp lệ.': 'Invalid reward ID.',
  '✦  HOÀN THÀNH!  ✦': '✦  STAGE CLEAR!  ✦',
  'KHÓA': 'LOCKED',
  'Bóng Mơ': 'Shadow',
  'Kéo đèn · Dẫn bóng về cửa': 'Drag lamp · Guide shadow to door',
  'MÀN': 'STAGE',
  'Đánh thức ánh sáng': 'Awaken the light',
  'Đèn sang trái, bóng sang phải. Đưa cả bóng vào cửa trăng.': 'Move the lamp left to move the shadow right. Guide it fully into the moon door.',
  'Qua miền gai đỏ': 'Across the red thorns',
  'Đi dưới cảm biến đỏ, rồi đưa bóng lên cửa trăng.':
      'Pass below the red sensor, then guide the shadow up to the moon door.',
  'Chìa khóa sân khấu': 'The stage key',
  'Chạm ngôi sao bên trái để mở cửa chắn, rồi về cửa trăng.':
      'Touch the star on the left to open the gate, then reach the moon door.',
  'Gốc cây trăng': 'Moon tree roots',
  'Đạo cụ tối chỉ chắn bóng. Đi vòng dưới gốc cây.':
      'Dark props block the shadow. Go around the roots below.',
  'Hồ lá tím': 'Violet leaf lake',
  'Tìm lối bên trái giữa hai đảo giấy.':
      'Find the left path between two paper islands.',
  'Nhà kính trăng': 'Moon greenhouse',
  'Bóng dừng ở đạo cụ, chạm coral sẽ thua.':
      'Props stop the shadow; touching coral ends the attempt.',
  'Cổng hoa khuya': 'Midnight flower gate',
  'Đổi hướng hai lần để qua cổng hoa.':
      'Change direction twice to pass the flower gate.',
  'Màn chớp đầu tiên': 'The first shutter',
  'Đợi chớp lên rồi băng qua dưới.':
      'Wait for the shutter to rise, then pass underneath.',
  'Bánh răng ngập sao': 'Starbound gears',
  'Chờ ở khoảng trống bên dưới bánh răng.': 'Wait in the gap below the gear.',
  'Ròng rọc giấy': 'Paper pulleys',
  'Qua sao trước khi tới cửa chắn.':
      'Touch the star before approaching the gate.',
  'Hai nhịp đồng': 'Two brass beats',
  'Bật sao theo thứ tự rồi né chớp ở giữa.':
      'Activate the stars in order, then avoid the middle shutter.',
  'Đồng hồ thiên văn': 'Astral clock',
  'Chờ khoảng trống giữa hai màn chớp.':
      'Wait for the gap between the two shutters.',
  'Trang sách mở': 'An open page',
  'Bật sao; vòng mint báo lúc cửa khép.':
      'Activate the star; the mint ring shows when the gate closes.',
  'Hành lang sách': 'Book corridor',
  'Sau sao cuối, chọn đường ngắn.': 'After the last star, take the short path.',
  'Phòng bản đồ trăng': 'Moon map room',
  'Sau sao cuối, lách trên rồi xuống giữa hai vách giấy.':
      'After the last star, weave above and then between the two paper walls.',
  'Gác chuông giấy': 'Paper bell tower',
  'Chờ chớp đi xa, bật sao rồi qua cửa.': 'Wait for the shutter to move away, activate the star, then pass the door.',
  'Mở rèm thiên hà': 'Parting the galaxy curtains',
  'Né cảm biến đứng và chớp ngang qua hành lang.':
      'Avoid the fixed sensor and the shutter crossing the corridor.',
  'Quỹ đạo trăng': 'Moon orbit',
  'Hai sao, một chớp và cửa sắp khép.':
      'Two stars, one shutter, and a closing gate.',
  'Ba nhịp sân khấu': 'Three stage beats',
  'Bật ba sao rồi luồn chữ S qua hai vách.':
      'Activate three stars, then weave in an S between two walls.',
  'Đại cảnh Rạp bóng nhỏ': 'Little Shadow Theatre finale',
  'Ba sao, chớp dọc sát mép và chớp ngang.':
      'Three stars, a full-height shutter, and a crossing shutter.',
};
