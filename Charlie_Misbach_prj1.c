#include <stdio.h>

int compare(int num1, int num2) {
    if (num1 < num2) return -1;
    else if (num1 > num2) return 1;
    else return 0;
}

int merge (int * arr1, int * arr2, int * output, int size) {
    int i = 0; // i will increment for arr1
    int j = 0; // j will increment for arr2
    int cnt = 0; // counts number of elements to output

    /*
    Iterate over both arrays until i and j exceeds
    the size of the arrays (they're equal in size)
    */
    while (i < size && j < size) {

        if(compare(arr1[i], arr2[j]) == -1) {
            output[cnt] = arr1[i];
            cnt++;
            i++;
        } else if (compare(arr1[i], arr2[j]) == 1) {
            output[cnt] = arr2[j];
            cnt++;
            j++;
        } else {
            output[cnt] = arr2[j];
            cnt++;
            j++;
        }
    }

    // Copy the remaining elements from arr1, if any
    while (i < size) {
        output[cnt] = arr1[i];
        cnt++;
        i++;
    }

    // Copy the remaining elements from arr2, if any
    while (j < size) {
        output[cnt] = arr2[j];
        cnt++;
        j++;
    }

    return cnt;
}

void merge2(int * arr1, int * bufferedArr, int size) {
    int i = size - 1; // Index of the last element in arr1
    int j = size - 1; // Index of the last element in the initial segment of bufferedArr
    int k = (size * 2) - 1; // Index for the last position in bufferedArr
    
    // Merge arr1 and the initial segment of bufferedArr starting from the end
    while (j >= 0) {
        // Compare elements and place the larger element in the correct position from the end
        if (i >= 0 && compare(arr1[i], bufferedArr[j]) > 0) {
            bufferedArr[k] = arr1[i];
            k--;
            i--;
        } else {
            bufferedArr[k] = bufferedArr[j];
            k--;
            j--;
        }
    }
    
    // If any elements remain in arr1, copy them to bufferedArr
    while (i >= 0) {
        bufferedArr[k] = arr1[i];
        k--;
        i--;
    }
}

int main() {
    // Example arrays
    int arr1[] = {5, 7, 18, 20, 24, 30};
    int arr2[] = {4, 6, 14, 23, 24, 31};
    int size = sizeof(arr1) / sizeof(arr1[0]); // Size of each input array
    
    // Output array for the merge function
    int output[size * 2]; 
    
    // Merge arr1 and arr2 into output
    merge(arr1, arr2, output, size);
    
    // Print the result of the merge function
    printf("Merged array using merge function: \n");
    for (int i = 0; i < size * 2; i++) {
        printf("%d ", output[i]);
    }
    printf("\n\n");

    // Prepare bufferedArr for the merge2 function
    // Note: The initial elements are copied manually as shown earlier
    int bufferedArr[2 * size];
    for (int i = 0; i < size; i++) { // Copy initial elements from arr2 to bufferedArr
        bufferedArr[i] = arr2[i];
    }
    for (int i = size; i < 2 * size; i++) { // Initialize buffer space with 0 or suitable value
        bufferedArr[i] = 0; // Placeholder value, not necessary if you're okay with uninitialized space
    }

    // Merge arr1 into bufferedArr using merge2 function
    merge2(arr1, bufferedArr, size);
    
    // Print the result of the merge2 function
    printf("Buffered array after merge2 function: \n");
    for (int i = 0; i < size * 2; i++) {
        printf("%d ", bufferedArr[i]);
    }
    printf("\n");

    return 0;
}