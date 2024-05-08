import pandas as pd

def kSub(k, nums):
    # Initialize the hashmap and other variables
    prefix_sum_count = {0: 1}  # There is one prefix sum that is zero initially
    prefix_sum = 0
    total_count = 0

    # Iterate through the array
    for num in nums:
        # Update the prefix sum
        prefix_sum += num
        # Compute the modulo k of the current prefix sum
        mod_k = prefix_sum % k
        # If this modulo k has been seen before, add the count to the total count
        if mod_k in prefix_sum_count:
            total_count += prefix_sum_count[mod_k]
        # Increment the count of this modulo k in the hashmap
        prefix_sum_count[mod_k] = prefix_sum_count.get(mod_k, 0) + 1

    return total_count

# Example usage:
k = 5
nums = [5, 10, 11, 9, 5]
# Call the function and print the result
kSub(k, nums)