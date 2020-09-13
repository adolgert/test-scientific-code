def running_average(x, duration, orientation, fill):
    offsets = {
        "past": 1 - duration,
        "future": 0,
        "midpoint": 1 - ((duration + 1) // 2)
        }
    offset_in_window = offsets[orientation]

    result = x[0:len(x)]
    if fill:
        filled = x[:1] * (duration - 1) + x + x[-1:] * (duration - 1)
        offset_in_window += duration - 1
        for i in range(0, len(x)):
            a, b = [i + offset_in_window, i + duration + offset_in_window]
            result[i] = sum(filled[a:b]) / duration
    else:
        for i in range(0, len(x)):
            a, b = [i + offset_in_window, i + duration + offset_in_window]
            left = max(a, 0)
            right = min(b, len(x))
            result[i] = sum(x[left:right]) / (right - left)
    return result


def nearly(a, b):
    matched = all(abs(x - y) < 1e-7 for (x, y) in zip(a, b))
    if not matched:
        print(b)
    return matched


def test_running_average_single_past():
    x = [1,2,3,4,5]
    y = running_average(x, 1, "past", False)
    assert nearly(x, y)

def test_running_average_single_future():
    x = [1,2,3,4,5]
    y = running_average(x, 1, "future", False)
    assert nearly(x, y)

def test_running_average_single_midpoint():
    x = [1,2,3,4,5]
    y = running_average(x, 1, "midpoint", False)
    assert nearly(x, y)

def test_running_average_single_past_fill():
    x = [1,2,3,4,5]
    y = running_average(x, 1, "past", True)
    assert nearly(x, y)

def test_running_average_single_future_fill():
    x = [1,2,3,4,5]
    y = running_average(x, 1, "future", True)
    assert nearly(x, y)

def test_running_average_single_midpoint_true():
    x = [1,2,3,4,5]
    y = running_average(x, 1, "midpoint", True)
    assert nearly(x, y)

def test_running_average_double_past():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 2, "past", False)
    answer = [1, 1.5, 2.5, 3.5, 4.5]
    assert nearly(answer, y)

def test_running_average_double_future():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 2, "future", False)
    answer = [1.5, 2.5, 3.5, 4.5, 5]
    assert nearly(answer, y)

def test_running_average_double_midpoint():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 2, "midpoint", False)
    answer = [1.5, 2.5, 3.5, 4.5, 5]
    assert nearly(answer, y)

def test_running_average_double_past_fill():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 2, "past", True)
    answer = [1, 1.5, 2.5, 3.5, 4.5]
    assert nearly(answer, y)

def test_running_average_double_future_fill():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 2, "future", True)
    answer = [1.5, 2.5, 3.5, 4.5, 5]
    assert nearly(answer, y)

def test_running_average_double_midpoint_fill():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 2, "midpoint", True)
    answer = [1.5, 2.5, 3.5, 4.5, 5]
    assert nearly(answer, y)

def test_running_average_triple_past():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 3, "past", False)
    answer = [1, 1.5, 2, 3, 4]
    assert nearly(answer, y)

def test_running_average_triple_future():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 3, "future", False)
    answer = [2, 3, 4, 4.5, 5]
    assert nearly(answer, y)

def test_running_average_triple_midpoint():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 3, "midpoint", False)
    answer = [1.5, 2, 3, 4, 4.5]
    assert nearly(answer, y)

def test_running_average_triple_past_fill():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 3, "past", True)
    answer = [1, 4 / 3, 2, 3, 4]
    assert nearly(answer, y)

def test_running_average_triple_future_fill():
    x = [1, 2, 3, 4, 5]
    y = running_average(x, 3, "future", True)
    answer = [2, 3, 4, 14 / 3, 5]
    assert nearly(answer, y)

def test_running_average_triple_midpoint_fill():
    x = [1, 2, 3, 4 ,5]
    y = running_average(x, 3, "midpoint", True)
    answer = [4 / 3, 2, 3, 4, 14 / 3]
    assert nearly(answer, y)
